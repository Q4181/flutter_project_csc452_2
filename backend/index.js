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
            res.status(500).json({ error: 'Error fetching foods: ' + err.message });
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
            res.status(500).json({ error: 'Error fetching nutrients: ' + err.message });
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
            res.status(500).json({ error: 'Error fetching foods with nutrients: ' + err.message });
        } else {
            res.json(results);
        }
    });
});

// ✅ API: Create a new food
app.post('/foods', (req, res) => {
    const { food_name, category, serving_size, image_url } = req.body;
    if (!food_name || !category || !serving_size) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    connection.query(
        'INSERT INTO Foods (food_name, category, serving_size, image_url) VALUES (?, ?, ?, ?)',
        [food_name, category, serving_size, image_url || null],
        (err, results) => {
            if (err) {
                console.error('❌ Error creating food:', err.message);
                res.status(500).json({ error: 'Error creating food: ' + err.message });
            } else {
                res.status(201).json({ food_id: results.insertId, message: 'Food created' });
            }
        }
    );
});

// ✅ API: Update a food
app.put('/foods/:id', (req, res) => {
    const { food_name, category, serving_size, image_url } = req.body;
    const food_id = req.params.id;
    connection.query(
        'UPDATE Foods SET food_name = ?, category = ?, serving_size = ?, image_url = ? WHERE food_id = ?',
        [food_name, category, serving_size, image_url || null, food_id],
        (err, results) => {
            if (err) {
                console.error('❌ Error updating food:', err.message);
                res.status(500).json({ error: 'Error updating food: ' + err.message });
            } else if (results.affectedRows === 0) {
                res.status(404).json({ error: 'Food not found' });
            } else {
                res.json({ message: 'Food updated' });
            }
        }
    );
});

// ✅ API: Delete a food
app.delete('/foods/:id', (req, res) => {
    const food_id = req.params.id;
    connection.query(
        'DELETE FROM Foods WHERE food_id = ?',
        [food_id],
        (err, results) => {
            if (err) {
                console.error('❌ Error deleting food:', err.message);
                res.status(500).json({ error: 'Error deleting food: ' + err.message });
            } else if (results.affectedRows === 0) {
                res.status(404).json({ error: 'Food not found' });
            } else {
                res.json({ message: 'Food deleted' });
            }
        }
    );
});

// ✅ API: Create a new nutrient
app.post('/nutrients', (req, res) => {
    const { food_id, protein, fat, carbohydrates, fiber, sugar, sodium } = req.body;
    if (!food_id) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    connection.query(
        'INSERT INTO Nutrients (food_id, protein, fat, carbohydrates, fiber, sugar, sodium) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [food_id, protein || 0, fat || 0, carbohydrates || 0, fiber || 0, sugar || 0, sodium || 0],
        (err, results) => {
            if (err) {
                console.error('❌ Error creating nutrient:', err.message);
                res.status(500).json({ error: 'Error creating nutrient: ' + err.message });
            } else {
                res.status(201).json({ nutrient_id: results.insertId, message: 'Nutrient created' });
            }
        }
    );
});

// ✅ API: Update a nutrient
app.put('/nutrients/:id', (req, res) => {
    const { food_id, protein, fat, carbohydrates, fiber, sugar, sodium } = req.body;
    const nutrient_id = req.params.id;
    connection.query(
        'UPDATE Nutrients SET food_id = ?, protein = ?, fat = ?, carbohydrates = ?, fiber = ?, sugar = ?, sodium = ? WHERE nutrient_id = ?',
        [food_id, protein || 0, fat || 0, carbohydrates || 0, fiber || 0, sugar || 0, sodium || 0, nutrient_id],
        (err, results) => {
            if (err) {
                console.error('❌ Error updating nutrient:', err.message);
                res.status(500).json({ error: 'Error updating nutrient: ' + err.message });
            } else if (results.affectedRows === 0) {
                res.status(404).json({ error: 'Nutrient not found' });
            } else {
                res.json({ message: 'Nutrient updated' });
            }
        }
    );
});

// ✅ API: Delete a nutrient
app.delete('/nutrients/:id', (req, res) => {
    const nutrient_id = req.params.id;
    connection.query(
        'DELETE FROM Nutrients WHERE nutrient_id = ?',
        [nutrient_id],
        (err, results) => {
            if (err) {
                console.error('❌ Error deleting nutrient:', err.message);
                res.status(500).json({ error: 'Error deleting nutrient: ' + err.message });
            } else if (results.affectedRows === 0) {
                res.status(404).json({ error: 'Nutrient not found' });
            } else {
                res.json({ message: 'Nutrient deleted' });
            }
        }
    );
});

// ✅ Start server
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`🚀 Server listening on port ${port}`);
});

// 📦 For deployment (e.g., Vercel)
module.exports = app;