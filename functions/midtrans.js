const midtransClient = require('midtrans-client');
const admin = require('firebase-admin');

// Konfigurasi Midtrans dengan kredensial Anda
// Merchant ID: G562390311
const snap = new midtransClient.Snap({
  isProduction: false, // Set false untuk sandbox/testing
  serverKey: 'REDACTED_OLD_SERVER_KEY',
  clientKey: 'REDACTED_OLD_CLIENT_KEY'
});

/**
 * Create Midtrans Transaction
 * Endpoint untuk membuat transaksi pembayaran
 */
exports.createMidtransTransaction = async (data, context) => {
  // Validasi user authentication
  if (!context.auth) {
    throw new Error('User must be authenticated');
  }

  const userId = context.auth.uid;
  const {
    orderId,
    amount,
    customerName,
    customerEmail,
    customerPhone,
    items
  } = data;

  // Validasi input
  if (!orderId || !amount || !customerName || !customerEmail) {
    throw new Error('Missing required fields');
  }

  try {
    // Parameter untuk Midtrans
    const parameter = {
      transaction_details: {
        order_id: orderId,
        gross_amount: Math.round(amount) // Midtrans hanya menerima integer
      },
      customer_details: {
        first_name: customerName,
        email: customerEmail,
        phone: customerPhone || ''
      },
      item_details: items.map(item => ({
        id: item.id,
        price: Math.round(item.price),
        quantity: item.quantity,
        name: item.name
      })),
      callbacks: {
        finish: 'https://your-app.com/payment-success',
        error: 'https://your-app.com/payment-error',
        pending: 'https://your-app.com/payment-pending'
      }
    };

    // Buat transaksi di Midtrans
    const transaction = await snap.createTransaction(parameter);

    // Simpan ke Firestore
    await admin.firestore().collection('transactions').doc(orderId).set({
      userId: userId,
      orderId: orderId,
      amount: amount,
      status: 'pending',
      paymentUrl: transaction.redirect_url,
      token: transaction.token,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      customerDetails: {
        name: customerName,
        email: customerEmail,
        phone: customerPhone
      }
    });

    return {
      success: true,
      token: transaction.token,
      redirectUrl: transaction.redirect_url
    };
  } catch (error) {
    console.error('Error creating transaction:', error);
    throw new Error(`Failed to create transaction: ${error.message}`);
  }
};

/**
 * Handle Midtrans Webhook/Notification
 * Endpoint untuk menerima notifikasi status pembayaran dari Midtrans
 */
exports.handleMidtransNotification = async (req, res) => {
  try {
    const notification = req.body;

    // Verifikasi signature (penting untuk keamanan)
    const statusResponse = await snap.transaction.notification(notification);
    
    const orderId = statusResponse.order_id;
    const transactionStatus = statusResponse.transaction_status;
    const fraudStatus = statusResponse.fraud_status;

    let paymentStatus = 'pending';

    // Mapping status Midtrans ke status internal
    if (transactionStatus === 'capture') {
      if (fraudStatus === 'accept') {
        paymentStatus = 'success';
      }
    } else if (transactionStatus === 'settlement') {
      paymentStatus = 'success';
    } else if (
      transactionStatus === 'cancel' ||
      transactionStatus === 'deny' ||
      transactionStatus === 'expire'
    ) {
      paymentStatus = 'failed';
    } else if (transactionStatus === 'pending') {
      paymentStatus = 'pending';
    }

    // Update status di Firestore
    await admin.firestore().collection('transactions').doc(orderId).update({
      status: paymentStatus,
      transactionStatus: transactionStatus,
      fraudStatus: fraudStatus,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      midtransResponse: statusResponse
    });

    // Update order status jika pembayaran berhasil
    if (paymentStatus === 'success') {
      await admin.firestore().collection('orders').doc(orderId).update({
        paymentStatus: 'paid',
        orderStatus: 'processing',
        paidAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * Check Transaction Status
 * Fungsi untuk mengecek status transaksi
 */
exports.checkTransactionStatus = async (data, context) => {
  if (!context.auth) {
    throw new Error('User must be authenticated');
  }

  const { orderId } = data;

  if (!orderId) {
    throw new Error('Order ID is required');
  }

  try {
    // Get status dari Midtrans
    const statusResponse = await snap.transaction.status(orderId);

    // Update di Firestore
    const docRef = admin.firestore().collection('transactions').doc(orderId);
    const doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        transactionStatus: statusResponse.transaction_status,
        fraudStatus: statusResponse.fraud_status,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    return {
      success: true,
      status: statusResponse.transaction_status,
      orderId: orderId
    };
  } catch (error) {
    console.error('Error checking status:', error);
    throw new Error(`Failed to check status: ${error.message}`);
  }
};
