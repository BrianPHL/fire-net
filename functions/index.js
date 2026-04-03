const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp();

const ALERTS_TOPIC = 'alerts';

exports.sendAlertNotification = functions.firestore
  .document('alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alert = snap.data();
    if (!alert) {
      return null;
    }

    const severity = String(alert.severity || '').toLowerCase();
    if (severity !== 'warning' && severity !== 'danger') {
      return null;
    }

    const title = severity === 'danger' ? 'Danger Alert' : 'Warning Alert';
    const body = `${alert.nodeName || 'Sensor'} at ${alert.location || 'Unknown location'} needs attention.`;

    const triggeredAt = alert.triggeredAt && typeof alert.triggeredAt.toMillis === 'function'
      ? String(alert.triggeredAt.toMillis())
      : String(Date.now());

    const message = {
      topic: ALERTS_TOPIC,
      notification: {
        title,
        body,
      },
      data: {
        screen: 'alertDetail',
        alertId: context.params.alertId,
        title: String(alert.title || title),
        description: String(alert.description || body),
        severity,
        nodeId: String(alert.nodeId || ''),
        nodeName: String(alert.nodeName || 'Unknown Node'),
        location: String(alert.location || 'Unknown'),
        triggeredAt,
        status: String(alert.status || 'active'),
        explanation: String(alert.explanation || ''),
        createdBy: String(alert.createdBy || ''),
        resolvedBy: String(alert.resolvedBy || ''),
        updatedAt: String(Date.now()),
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'alerts_channel',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            contentAvailable: true,
          },
        },
      },
    };

    await admin.messaging().send(message);
    return null;
  });
