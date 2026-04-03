// This Service Worker is used for Firebase Cloud Messaging on web.

importScripts("https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js");

// Handle background messages
// Check if firebase and messaging are available
if (typeof firebase !== 'undefined' && firebase.messaging && firebase.messaging.isSupported()) {
  try {
    const messaging = firebase.messaging();
    messaging.onBackgroundMessage((payload) => {
      console.log('[firebase-messaging-sw.js] Received background message:', payload);
      
      const notificationTitle = payload.notification?.title || 'New Notification';
      const notificationOptions = {
        body: payload.notification?.body || 'You have a new message',
        icon: 'icons/Icon-192.png',
        badge: 'icons/Icon-192.png',
        tag: 'firebase-messaging',
        data: payload.data || {},
      };

      return self.registration.showNotification(notificationTitle, notificationOptions);
    });
  } catch (error) {
    console.error('[firebase-messaging-sw.js] Error setting up background message handler:', error);
  }
} else {
  console.warn('[firebase-messaging-sw.js] Firebase messaging is not available');
}
// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      // Check if any client is already open
      for (let i = 0; i < windowClients.length; i++) {
        const client = windowClients[i];
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      // If not, open a new window
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    }).catch((error) => {
      console.error('[firebase-messaging-sw.js] Error handling notification click:', error);
    })
  );
});

