
// **** node-s3.js ****
/*
Author : Jan Jilek - https://github.com/janjilek
*/

var aws = require('aws-sdk');
var config = require('config');
var crypto = require('crypto');
var mime = require('mime');
var awsConfig = config.get('amazon.aws');
aws.config.update(awsConfig);
var s3 = new aws.S3();
var AmazonService = (function () {
    function AmazonService() {
    }

    //Input parameter "key" example : var key = 'files/' + fileId + '/' + uuid.v4() + '.' + extension;
    //Input parameter "uuid" is the fileId from previous row
    //Example of call : AmazonService.getUploadPayload(fileId, key, null, null, [], function(err, data) {})

    AmazonService.prototype.getUploadPayload = function (uuid, key, maxSize, expires, tags, cb) {
        if (!uuid) {
            return cb(new Error('amazonservice.uuid.is.null'));
        }
        if (!key) {
            return cb(new Error('amazonservice.key.is.null'));
        }
        if (!maxSize) {
            maxSize = 1024 * 1024 * 3;
        }
        if (!expires) {
            expires = 60 * 1000;
        }
        var dateObj = new Date();
        var dateExp = new Date(dateObj.getTime() + expires);
        var date = dateObj.getUTCFullYear() + ('0' + (dateObj.getUTCMonth() + 1)).slice(-2) + ('0' + dateObj.getUTCMonth()).slice(-2);
        var amzDate = date + 'T000000Z';
        var bucket = AmazonService.S3_BUCKET_NAME;
        var credential = awsConfig.accessKeyId + '/' + date + '/' + awsConfig.region + '/s3/aws4_request';
        var algorithm = 'AWS4-HMAC-SHA256';
        var type = mime.lookup(key);
        var expiration = dateExp.getUTCFullYear()
            + '-' + (dateExp.getUTCMonth() + 1)
            + '-' + dateExp.getUTCDate()
            + 'T' + dateExp.getUTCHours()
            + ':' + dateExp.getUTCMinutes()
            + ':' + dateExp.getUTCSeconds()
            + 'Z';
        var policy = {
            'expiration': expiration,
            'conditions': [
                { 'bucket': bucket },
                { 'key': key },
                ['starts-with', '$x-amz-meta-tag', ''],
                { 'Content-Type': type },
                ['content-length-range', 0, maxSize],
                { 'x-amz-credential': credential },
                { 'x-amz-date': amzDate },
                { 'x-amz-algorithm': algorithm },
                { 'x-amz-meta-uuid': uuid },
            ]
        };
        var policyString = JSON.stringify(policy);
        var policyBase64 = new Buffer(policyString).toString('base64');
        var secretKey = awsConfig.secretAccessKey;
        var region = awsConfig.region;
        var dateKey = crypto.createHmac('sha256', 'AWS4' + secretKey);
        dateKey.update(date);
        var dateRegionKey = crypto.createHmac('sha256', dateKey.digest('buffer'));
        dateRegionKey.update(region);
        var dateRegionServiceKey = crypto.createHmac('sha256', dateRegionKey.digest('buffer'));
        dateRegionServiceKey.update('s3');
        var signingKey = crypto.createHmac('sha256', dateRegionServiceKey.digest('buffer'));
        signingKey.update('aws4_request');
        var signature = crypto.createHmac('sha256', signingKey.digest('buffer'));
        signature.update(policyBase64);
        var payload = {
            key: key,
            'Content-Type': type,
            'x-amz-meta-uuid': uuid,
            'x-amz-meta-tag': tags,
            'X-Amz-Credential': credential,
            'Policy': policyBase64,
            'X-Amz-Signature': signature.digest('hex'),
            'X-Amz-Algorithm': algorithm,
            'X-Amz-Date': amzDate
        };
        var payloadOrder = [
            'key',
            'Content-Type',
            'x-amz-meta-uuid',
            'x-amz-meta-tag',
            'X-Amz-Credential',
            'Policy',
            'X-Amz-Signature',
            'X-Amz-Algorithm',
            'X-Amz-Date'
        ];
        var url = 'https://' + bucket + '.s3.amazonaws.com/';
        var method = 'post';
        var fileField = 'file';
        cb(null, {
            field: fileField,
            method: method,
            payload: payload,
            payloadOrder: payloadOrder,
            url: url
        });
    };
    AmazonService.prototype.getUrl = function (key, expires, cb) {
        if (!key) {
            return cb(new Error('amazonservice.key.is.null'));
        }
        if (!expires) {
            expires = 24 * 60 * 60 * 1000;
        }
        var params = {
            Bucket: AmazonService.S3_BUCKET_NAME,
            Expires: expires,
            Key: key
        };
        s3.getSignedUrl('getObject', params, function (err, data) {
            if (err) {
                return cb(err);
            }
            cb(null, data);
        });
    };
    AmazonService.S3_TYPE_VIDEO = 'video';
    AmazonService.S3_TYPE_AUDIO = 'audio';
    AmazonService.S3_BUCKET_NAME = 'YOUR_BUCKET_NAME';
    return AmazonService;
})();
module.exports = new AmazonService();
