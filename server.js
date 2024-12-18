const http = require("http");
const { Server } = require("socket.io");

const server = http.createServer();
const io = new Server(server);

const PORT = 12345;

// Mappatura di utenti registrati: username -> socket.id
const users = {};

// Quando un client si connette
io.on("connection", (socket) => {
  console.log("Un client si è connesso.");

  // Gestisce la registrazione dell'utente
  socket.on("register", (username) => {
    if (username) {
      users[username] = socket.id;
      console.log(`${username} registrato con socket ID ${socket.id}`);
      updateUserList();
    }
  });

  // Gestisce l'invio di messaggi privati
  socket.on("private_message", (data) => {
    const { recipient, message } = data;

    if (users[recipient]) {
      const recipientSocketId = users[recipient];
      io.to(recipientSocketId).emit("message", {
        sender: getUsernameBySocketId(socket.id),
        message,
      });
      console.log(
        `Messaggio inviato da ${getUsernameBySocketId(socket.id)} a ${recipient}`,
      );
    } else {
      console.log(
        `Messaggio non consegnato. Destinatario ${recipient} non trovato.`,
      );
    }
  });

  // Quando un client si disconnette
  socket.on("disconnect", () => {
    const username = getUsernameBySocketId(socket.id);
    if (username) {
      delete users[username];
      console.log(`${username} si è disconnesso.`);
      updateUserList();
    }
  });

  // Funzione per aggiornare la lista degli utenti online
  const updateUserList = () => {
    const usernames = Object.keys(users);
    io.emit("users", usernames);
  };

  // Funzione per ottenere il nome utente dato un socket ID
  const getUsernameBySocketId = (socketId) => {
    return Object.keys(users).find((username) => users[username] === socketId);
  };
});

server.listen(PORT, () => {
  console.log(`Server in ascolto sulla porta ${PORT}`);
});
