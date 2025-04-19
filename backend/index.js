const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// ✅ Connect to TiDB
const connection = mysql.createConnection({ uri: process.env.DATABASE_URL });

connection.connect((err) => {
    if (err) {
        console.error('❌ Cannot connect to database:', err);
        return;
    }
    console.log('✅ Connected to TiDB database!');
});

// 🌐 Routes

// Test route
app.get('/', (req, res) => {
    res.send('Hello world!!');
});

// ✅ API: Get all foods
app.get('/foods', (req, res) => {
    connection.query('SELECT * FROM Foods', (err, results) => {
        if (err) {
            console.error('❌ Error fetching foods:', err.message);
            res.status(500).send('Error fetching foods: ' + err.message);
        } else {
            res.json(results);
        }
    });
});

// ✅ API: Get all nutrients
app.get('/nutrients', (req, res) => {
    connection.query('SELECT * FROM Nutrients', (err, results) => {
        if (err) {
            console.error('❌ Error fetching nutrients:', err.message);
            res.status(500).send('Error fetching nutrients: ' + err.message);
        } else {
            res.json(results);
        }
    });
});

// ✅ API: Get foods with nutrients
app.get('/foods/nutrients', (req, res) => {
    connection.query(`
        SELECT f.food_id, f.food_name, f.category, f.serving_size, f.image_url,
               n.nutrient_id, n.protein, n.fat, n.carbohydrates, n.fiber, n.sugar, n.sodium
        FROM Foods f
        LEFT JOIN Nutrients n ON f.food_id = n.food_id
    `, (err, results) => {
        if (err) {
            console.error('❌ Error fetching foods with nutrients:', err.message);
            res.status(500).send('Error fetching foods with nutrients: ' + err.message);
        } else {
            res.json(results);
        }
    });
});

// ✅ Start server
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`🚀 Server listening on port ${port}`);
});

// 📦 For deployment (e.g., Vercel)
module.exports = app;