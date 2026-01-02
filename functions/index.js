// Simulated payment + notifications for academic use (no real gateway)
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.createPaymentRecord = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }
  const { orderId, paymentMethod, cardLast4, cardHolder, cardCountry } = data;
  if (!orderId || !paymentMethod) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing args');
  }

  const orderRef = admin.firestore().collection('orders').doc(orderId);
  const orderSnap = await orderRef.get();
  if (!orderSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Order not found');
  }
  const order = orderSnap.data();
  if (order.userId !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'Not your order');
  }

  const amount = order.totalPrice || 0; // server-side compute
  const paymentStatus = paymentMethod === 'Card' ? 'paid' : 'pending';

  await admin.firestore().collection('payments').add({
    userId: context.auth.uid,
    orderId,
    amount,
    paymentMethod,
    paymentStatus,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    card:
      paymentMethod === 'Card'
        ? { last4: cardLast4 || '', holder: cardHolder || '', country: cardCountry || '' }
        : null,
  });

  await orderRef.update({
    paymentMethod,
    orderStatus: paymentStatus === 'paid' ? 'paid' : 'processing',
  });

  await admin.firestore().collection('notifications').add({
    userId: context.auth.uid,
    orderId,
    type: paymentStatus === 'paid' ? 'payment_success' : 'payment_pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});

exports.onOrderStatusChange = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return;
    if (before.orderStatus === after.orderStatus) return;

    const status = after.orderStatus;
    const notifyTypes = {
      processing: 'order_processing',
      shipped: 'order_shipped',
      completed: 'order_completed_ready_rating',
      paid: 'payment_success',
    };
    const type = notifyTypes[status];
    if (!type) return;

    await admin.firestore().collection('notifications').add({
      userId: after.userId,
      orderId: context.params.orderId,
      type,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
