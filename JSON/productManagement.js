// JSON data representing products (as an example)
const productsData = `[
  {"id": 1, "name": "Laptop", "category": "Electronics", "price": 1200, "available": true},
  {"id": 2, "name": "Phone", "category": "Electronics", "price": 800, "available": false},
  {"id": 3, "name": "Shoes", "category": "Clothing", "price": 50, "available": true}
]`;

// Parse the JSON string into a JavaScript object (array)
const products = JSON.parse(productsData);

// Function to add a new product
function addProduct(newProduct) {
  products.push(newProduct);
  console.log('Product added:', newProduct);
}

// Function to update the price of a product by ID
function updatePrice(productId, newPrice) {
  const product = products.find(p => p.id === productId);
  
  if (product) {
    product.price = newPrice;
    console.log(`Price of product with ID ${productId} updated to ${newPrice}`);
  } else {
    console.log('Product not found');
  }
}

// Function to filter products based on availability
function filterAvailableProducts() {
  return products.filter(p => p.available === true);
}

// Function to filter products by category
function filterProductsByCategory(category) {
  return products.filter(p => p.category === category);
}

// Example usage
const newProduct = {
  id: 4,
  name: "Watch",
  category: "Accessories",
  price: 150,
  available: true
};

addProduct(newProduct);
console.log(products);  // Check the updated product catalog

updatePrice(1, 1100);  // Update the price of the product with ID 1
console.log(products);  // Check the updated product catalog

const availableProducts = filterAvailableProducts();
console.log('Available products:', availableProducts);

const electronicsProducts = filterProductsByCategory("Electronics");
console.log('Electronics products:', electronicsProducts);
