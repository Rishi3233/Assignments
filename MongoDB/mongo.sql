
-- Part 1: Basic MongoDB Commands and Queries

-- Step 1: Create Collections and Insert Data

-- Create Customers Collection
db.createCollection("customers");

-- Insert Customer Documents
db.customers.insertMany([
  { "_id": ObjectId("unique_id1"), "name": "Rishi Raj", "email": "rishi@example.com", "address": { "street": "123 Main St", "city": "Springfield", "zipcode": "12345" }, "phone": "555-1234", "registration_date": ISODate("2023-01-01T12:00:00Z") },
  { "_id": ObjectId("unique_id2"), "name": "Utsav Rai", "email": "utsav@example.com", "address": { "street": "456 Park Ave", "city": "Metropolis", "zipcode": "54321" }, "phone": "555-5678", "registration_date": ISODate("2023-02-02T08:30:00Z") },
  { "_id": ObjectId("unique_id3"), "name": "Sagar Das", "email": "sagar@example.com", "address": { "street": "789 Broadway", "city": "Gotham", "zipcode": "67890" }, "phone": "555-7890", "registration_date": ISODate("2023-03-03T14:45:00Z") },
  { "_id": ObjectId("unique_id4"), "name": "Shashikant Prabhakar", "email": "shashikant@example.com", "address": { "street": "101 Oak St", "city": "Rivertown", "zipcode": "10234" }, "phone": "555-1011", "registration_date": ISODate("2023-04-04T09:00:00Z") },
  { "_id": ObjectId("unique_id5"), "name": "Anmol Ramani", "email": "anmol@example.com", "address": { "street": "202 Maple Ave", "city": "Sunnyvale", "zipcode": "56789" }, "phone": "555-2022", "registration_date": ISODate("2023-05-05T18:20:00Z") }
]);

-- Create Orders Collection
db.createCollection("orders");

-- Insert Order Documents
db.orders.insertMany([
  { "_id": ObjectId("order_id1"), "order_id": "ORD123456", "customer_id": ObjectId("unique_id1"), "order_date": ISODate("2023-05-15T14:00:00Z"), "status": "shipped", "items": [{ "product_name": "Laptop", "quantity": 1, "price": 1500 }, { "product_name": "Mouse", "quantity": 2, "price": 25 }], "total_value": 1550 },
  { "_id": ObjectId("order_id2"), "order_id": "ORD123457", "customer_id": ObjectId("unique_id2"), "order_date": ISODate("2023-05-16T10:00:00Z"), "status": "delivered", "items": [{ "product_name": "Smartphone", "quantity": 1, "price": 800 }, { "product_name": "Charger", "quantity": 1, "price": 50 }], "total_value": 850 },
  { "_id": ObjectId("order_id3"), "order_id": "ORD123458", "customer_id": ObjectId("unique_id3"), "order_date": ISODate("2023-05-17T11:00:00Z"), "status": "pending", "items": [{ "product_name": "Keyboard", "quantity": 1, "price": 100 }, { "product_name": "Monitor", "quantity": 1, "price": 300 }], "total_value": 400 },
  { "_id": ObjectId("order_id4"), "order_id": "ORD123459", "customer_id": ObjectId("unique_id4"), "order_date": ISODate("2023-05-18T12:00:00Z"), "status": "shipped", "items": [{ "product_name": "Tablet", "quantity": 1, "price": 400 }, { "product_name": "Case", "quantity": 1, "price": 20 }], "total_value": 420 },
  { "_id": ObjectId("order_id5"), "order_id": "ORD123460", "customer_id": ObjectId("unique_id5"), "order_date": ISODate("2023-05-19T13:00:00Z"), "status": "processing", "items": [{ "product_name": "Headphones", "quantity": 2, "price": 100 }, { "product_name": "Microphone", "quantity": 1, "price": 150 }], "total_value": 350 }
]);

-- Find Orders for a Specific Customer
const customer = db.customers.findOne({ name: "Rishi Raj" });
db.orders.find({ customer_id: customer._id });

-- Find the Customer for a Specific Order
const order = db.orders.findOne({ order_id: "ORD123456" });
db.customers.findOne({ _id: order.customer_id });

-- Update Order Status
db.orders.updateOne({ order_id: "ORD123456" }, { $set: { status: "delivered" } });

-- Delete an Order
db.orders.deleteOne({ order_id: "ORD123456" });

-- Part 2: Aggregation Pipeline

-- Calculate Total Value of All Orders by Customer
db.orders.aggregate([
  { $group: { _id: "$customer_id", totalSpent: { $sum: "$total_value" } } },
  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customerDetails" } },
  { $unwind: "$customerDetails" },
  { $project: { customerName: "$customerDetails.name", totalSpent: 1 } }
]);

-- Group Orders by Status
db.orders.aggregate([
  { $group: { _id: "$status", count: { $sum: 1 } } }
]);

--List Customers with Their Recent Orders
db.orders.aggregate([
  { $sort: { order_date: -1 } },
  { $group: { _id: "$customer_id", latestOrder: { $first: "$$ROOT" } } },
  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customerDetails" } },
  { $unwind: "$customerDetails" },
  { $project: { customerName: "$customerDetails.name", email: "$customerDetails.email", order: "$latestOrder" } }
]);


-- Find the Most Expensive Order by Customer
db.orders.aggregate([
  { $sort: { total_value: -1 } },
  { $group: { _id: "$customer_id", mostExpensiveOrder: { $first: "$$ROOT" } } },
  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customerDetails" } },
  { $unwind: "$customerDetails" },
  { $project: { customerName: "$customerDetails.name", mostExpensiveOrder: "$mostExpensiveOrder" } }
]);


-- Part 3: Real-World Scenario with Relationships

--Find All Customers Who Placed Orders in the Last Month
db.orders.aggregate([
  { $match: { order_date: { $gte: new Date(new Date() - 30 * 24 * 60 * 60 * 1000) } } },
  { $lookup: { from: "customers", localField: "customer_id", foreignField: "_id", as: "customerDetails" } },
  { $unwind: "$customerDetails" },
  { $project: { customerName: "$customerDetails.name", email: "$customerDetails.email", orderDate: "$order_date" } }
]);


--Find All Products Ordered by a Specific Customer
const customer = db.customers.findOne({ name: "Rishi Raj" });
db.orders.aggregate([
  { $match: { customer_id: customer._id } },
  { $unwind: "$items" },
  { $group: { _id: "$items.product_name", totalQuantity: { $sum: "$items.quantity" } } }
]);


--Find the Top 3 Customers with the Most Expensive Total Orders
db.orders.aggregate([
  { $group: { _id: "$customer_id", totalSpent: { $sum: "$total_value" } } },
  { $sort: { totalSpent: -1 } },
  { $limit: 3 },
  { $lookup: { from: "customers", localField: "_id", foreignField: "_id", as: "customerDetails" } },
  { $unwind: "$customerDetails" },
  { $project: { customerName: "$customerDetails.name", totalSpent: 1 } }
]);


--Add a New Order for an Existing Customer
const customer = db.customers.findOne({ name: "Utsav Rai" });
db.orders.insertOne({
  order_id: "ORD123789",
  customer_id: customer._id,
  order_date: new ISODate(),
  status: "pending",
  items: [{ product_name: "Smartphone", quantity: 1, price: 800 }, { product_name: "Headphones", quantity: 2, price: 100 }],
  total_value: 1000
});


--Part 4: Bonus Challenge

--Find Customers Who Have Not Placed Orders
db.customers.aggregate([
  { $lookup: { from: "orders", localField: "_id", foreignField: "customer_id", as: "orders" } },
  { $match: { orders: { $size: 0 } } },
  { $project: { name: 1, email: 1 } }
]);

--Calculate the Average Number of Items Ordered per Order
db.orders.aggregate([
  { $unwind: "$items" },
  { $group: { _id: "$_id", itemCount: { $sum: "$items.quantity" } } },
  { $group: { _id: null, avgItemsPerOrder: { $avg: "$itemCount" } } }
]);


--Join Customer and Order Data Using $lookup
db.customers.aggregate([
  { $lookup: { from: "orders", localField: "_id", foreignField: "customer_id", as: "orders" } },
  { $unwind: "$orders" },
  { $project: { name: 1, email: 1, order_id: "$orders.order_id", total_value: "$orders.total_value", order_date: "$orders.order_date" } }
]);