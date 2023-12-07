const AWS = require('aws-sdk');
const sns = new AWS.SNS();

exports.handler = async (event) => {
  const snsParams = {
    Message: 'Access!',
    Subject: 'specific column access',
    TopicArn: 'your_sns_topic_arn',
  };

  try {
    await sns.publish(snsParams).promise();
    return { statusCode: 200, body: 'Message sent successfully!' };
  } catch (error) {
    console.error('Error publishing message to SNS:', error);
    return { statusCode: 500, body: 'Error publishing message to SNS' };
  }
};
