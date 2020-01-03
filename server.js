const express = require("express");
const app = express();

const PORT = process.env.PORT || 8080;

app.get("/", (req, res) => {
    res.send(`
        <h1>Node running on Docker</h1>       
    `);
});

app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
});