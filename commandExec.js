const { exec } = require('child_process');
const userInput = req.query.cmd;
exec(userInput, (err, stdout, stderr) => {
  console.log(stdout);
});
