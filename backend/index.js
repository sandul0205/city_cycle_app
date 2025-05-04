const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
var jwt = require('jsonwebtoken');
app.use(cors());
app.use(bodyParser.json());

const SECRET_KEY = 'e475fb30650e96a225b35b8ae288c8b01a4e83d90bfde3aa0858dfb6c7721fb4a8093bc66494b139613444c87e66e9e4313d282c669202c37a6d9a68f74aaf51052863b06b5aa1226d748303d7f8a842cb14de3d98d4eafd7fbb7e755a1ac7c029f39dcc72a0802419a33e2dea2ceb13542f04c152d7b5a89d860a20907180041984a697e997ed7442cb163299dfc91a2422cfdda2514d35198c5c8b14cfa9995be9f09aa0866e75103601753d6b3437936e60aca2929d1efbe3835e369927d4b033e18c7cc90f2d1ea7fe1e5ef31abfd2bb391e985f154a04689ca1f1a7433d98593bddcaf57e06950d168f1b99ea33cef080084c545a7d5decabba846ebf86';

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', 
  database: 'city_rental'
});

db.connect(err => {
  if (err) throw err;
  console.log('MySQL Connected');
});


app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const sql = "SELECT * FROM users WHERE email = ? AND password = ?";
  
  db.query(sql, [email, password], (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    if (result.length > 0) {
      const token = jwt.sign({ id:result[0].Id}, SECRET_KEY, { expiresIn: 86400 }); // 24 hours

      res.send({ success: true, user: result[0] , token :token });

      // res.json({ token });
      // console.log('Token:', token);
    } else {
      res.send({ success: false, message: 'Invalid credentials' });
    }
  });
});

app.get('/rentals_history', (req, res) => {
  const sql = "SELECT * From rentals where user_id = ?";
  const token = req.headers['authorization'];
  if (!token) return res.status(401).send({ message: 'No token provided' });

  jwt.verify(token, SECRET_KEY, (err, decoded) => {
    if (err) return res.status(500).send({ message: 'Failed to authenticate token' });
    const userId = decoded.id;
    db.query(sql, userId, (err, result) => {
      if (err) return res.status(500).send({ message: 'Server error' });
      res.send(result);
    }   
  
  );
});
});

app.post('/register', (req, res) => {
  const { Name, Email, Password, Phone } = req.body;
  const sql = "INSERT INTO users (Name, Email, Password, Phone) VALUES (?, ?, ?, ?)";
  db.query(sql, [Name, Email, Password, Phone], (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    res.send({ success: true, message: 'User registered successfully' });
  });
});

app.get('/bikes', (req, res) => {
  const sql = "SELECT * FROM bikes";
  db.query(sql, (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    res.send(result);
  });
} );

app.listen(3000, () => {
  console.log('Server running on port 3000');
});

app.get('/prices', (req, res) => {
  const sql = `SELECT type, cost, updated_date FROM prices ORDER BY updated_date DESC`;
  db.query(sql, (err, result) => {
    if (err) {
      console.error('Error fetching prices:', err);
      return res.status(500).json({ error: 'Database query error' });
    }
    res.json(result);
  });
});

app.get('/bike-availability', (req, res) => {
  const { bike_id } = req.query;
  if (!bike_id) {
    return res.status(400).json({ error: 'Bike ID is required' });
  }

  const sql = "SELECT isAvailable FROM bikes WHERE id = ?";
  db.query(sql, [bike_id], (err, result) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database query error' });
    }
    if (result.length > 0) {
      res.json({ availability: result[0].isAvailable });
    } else {
      res.status(404).json({ message: 'Bike not found' });
    }
  });
});

app.post('/update-bike-availability', (req, res) => {
  const { id , isAvailable } = req.body;
  

  const sql = "UPDATE bikes SET isAvailable = ? WHERE id = ?";
  db.query(sql, [isAvailable, id], (err, result) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database query error' });
    }
    if (result.affectedRows > 0) {
      res.json({ message: 'Availability updated successfully' });
    } else {
      res.status(404).json({ message: 'Bike not found' });
    }
  });
});

app.get('/bike-id', (req, res) => {
  const { name } = req.query;
  
  if (!name) {
    return res.status(400).json({ error: 'Bike name is required' });
  }

  const sql = "SELECT id,type FROM bikes WHERE name = ?";
  db.query(sql, [name], (err, result) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database query error' });
    }
    if (result.length > 0) {
      res.json({ id: result[0].id , type: result[0].type });
    } else {
      res.status(404).json({ message: 'Bike not found' });
    }
  });
});

app.get('/bike-name', (req, res) => {
  const { id } = req.body;
  
  if (!id) {
    return res.status(400).json({ error: 'Bike ID is required' });
  }
  const sql = "SELECT name FROM bikes WHERE id = ?";
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ error: 'Database query error' });
    }
    if (result.length > 0) {
      res.json({ name: result[0].name });
    } else {
      res.status(404).json({ message: 'Bike not found' });
    }
  });
} );



app.post('/rentals', async (req, res) => {
  const { bike_id, user_id, rental_date, end_rental_date, rental_cost} = req.body;
  await db.query(
    "INSERT INTO rentals (bike_id, user_id, rental_date, end_rental_date,rental_cost) VALUES (?, ?, ?, ?,?)",
    [bike_id, user_id, rental_date, end_rental_date,rental_cost],
  );
  res.status(201).json({ message: 'Rental added' });
});


app.post('/end_rental', async (req, res) => {
  const { id } = req.body;
  
  await db.query(
    "UPDATE bikes JOIN rentals ON rentals.bike_id = bikes.id SET bikes.isAvailable = 1 WHERE rentals.id = ?;",
    [id],

  );
  await db.query(
    "UPDATE rentals SET end_rental_date = NOW() WHERE id = ?",
    [id],
  );

  await db.query(
    "DELETE FROM rentals WHERE id = ?",
    [id],
  );

  res.status(200).json({ message: 'Rental ended' });
}
  );
 


app.get('/ongoing_rentals', (req, res) => {
  const sql = "SELECT rentals.id, rentals.user_id ,bikes.name,bikes.location,rentals.rental_date,rentals.end_rental_date,rentals.rental_cost FROM rentals inner join bikes on rentals.bike_id = bikes.id ";
  db.query(sql, (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    res.send(result);
  });
});

app.post('/end_rental_cost', (req, res) => {
  const { id } = req.body;

  const sql = `
    SELECT rentals.rental_date, prices.cost
    FROM rentals
    INNER JOIN bikes ON rentals.bike_id = bikes.id
    INNER JOIN prices ON prices.type = bikes.type
    WHERE rentals.id = ?
  `;

  db.query(sql, [id], (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    
    if (result.length > 0) {
      const rentalDate = new Date(result[0].rental_date);
      const currentDate = new Date();
      const timeDiff = Math.abs(currentDate - rentalDate);
      const diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24)); // At least 1 day charged
      const cost = result[0].cost * diffDays;

      res.send({ success: true, cost });
    } else {
      res.send({ success: false, message: 'Rental not found' });
    }
  });
});



app.post('/user_data', (req, res) => {
  const {Id} = req.body;
  const sql = "SELECT * FROM users WHERE Id = ?";
  db.query(sql, [Id], (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    if (result.length > 0) {
      res.send({ success: true, user: result[0] });
    } else {
      res.send({ success: false, message: 'Invalid credentials' });
    }
  }
  );
}
);

app.post('/update_user', (req, res) => {
  const {Id, Name, Email, Phone} = req.body;

  const sql = "UPDATE users SET Name = ?, Email = ?, Phone = ? WHERE Id = ?";
  db.query(sql, [Name, Email, Phone, Id], (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    if (result.affectedRows > 0) {
      res.send({ success: true, message: 'User updated successfully' });
    } else {
      res.send({ success: false, message: 'User not found' });
    }
  });
});

app.post('/update_password', (req, res) => {
  const {Id, Password} = req.body;

  const sql = "UPDATE users SET Password = ? WHERE Id = ?";
  db.query(sql, [Password, Id], (err, result) => {
    if (err) return res.status(500).send({ message: 'Server error' });
    if (result.affectedRows > 0) {
      res.send({ success: true, message: 'Password updated successfully' });
    } else {
      res.send({ success: false, message: 'User not found' });
    }
  });
});

