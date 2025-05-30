/* Name: Derek Greene
*  OSU Email: greenede@oregonstate.edu
*  Course: CS 374 Operating Systems I
*  Assignment: OTP
*  Due Date: 3/16/2025
*  Description: This program serves as an client in a one-time-pad system. Plaintext and key data are 
*               sent from this client to a server (enc_server.c) for encrpytion using a one-time pad generated by keygen (keygen.c).  
*
*  References:
*  The Linux Programming Interface: a Linux and UNIX system programming handbook. Kerrisk, M. (2010)
*/


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netdb.h>

#define BUFFER_SIZE 1024 // buffer size for sending/recieving data


/*
* Function to print error messages
* Parameters: const char *msg
* Returns: void
*/
void error(const char *msg) { 
  perror(msg); 
  exit(0); 
} 


/* 
* Function to create address struct for server
* Parameters: struct sockaddr_in* address, int portNumber
* Returns: void
*/
void setupAddressStruct(struct sockaddr_in* address, int portNumber, char* hostname) {
  memset((char*) address, '\0', sizeof(*address)); // clear address struct
  address->sin_family = AF_INET; // IPv4
  address->sin_port = htons(portNumber); // port num
  struct hostent* hostInfo = gethostbyname(hostname); // get server host info

  if (hostInfo == NULL) { 
    fprintf(stderr, "CLIENT: ERROR, no such host\n"); 
    exit(0); 
  }
  memcpy((char*) &address->sin_addr.s_addr, hostInfo->h_addr_list[0],hostInfo->h_length);
}


/*
* Function to check if input file contains valid characters
* Parameters: char* fileName
* Returns: int
*/
int validChars(char* fileName) {
  FILE* file = fopen(fileName, "r");
  char c;
  while ((c = fgetc(file)) != EOF) {
    if ((c < 'A' || c > 'Z') && c != ' ' && c != '\n') {
      fclose(file);
      return 0; // invalid char found
    }
  }
  fclose(file);
  return 1;   // all valid chars
}


/*
* Function to read file data into buffer
* Parameters: char* fileName, long *fileSize
* Returns: char*
*/
char* processFile(char* fileName, long *fileSize) {
  struct stat fileStat;
  FILE* file = fopen(fileName, "r");

  if (file == NULL) {
    error("CLIENT: ERROR opening file");
  }

  stat(fileName, &fileStat);
  *fileSize = fileStat.st_size;  // get file size
 
  // check for valid chars
  if (!validChars(fileName)) {
    fprintf(stderr, "error: input contains bad characters");
    exit(1);
  }

  // read file data into buffer & allocate memory
  char* buffer = malloc(*fileSize + 1);
  fread(buffer, 1, *fileSize, file);
  buffer[*fileSize] = '\0'; // add null terminator
  fclose(file);
  return buffer;
}


/*
* Main Function
* Parameters: int argc, char *argv[]
* Returns: int
*/
int main(int argc, char *argv[]) {
  int socketFD, windowSize, totalSent, totalReceived, bytesSent, 
  bytesReceived, remainingBytes, messageSize, encryptedSize;
  struct sockaddr_in serverAddress;
  char buffer[BUFFER_SIZE];
  char *plaintext, *key, *encryptedData;
  long plaintextSize, keySize;
  
  // check for correct argument count
  if (argc < 4) { 
    fprintf(stderr, "USAGE: %s plaintext key port\n", argv[0]); 
    exit(0); 
  } 
  
  // read plaintext and key data into buffers
  plaintext = processFile(argv[1], &plaintextSize);
  key = processFile(argv[2], &keySize);

  // check if key is too short
  if (keySize < plaintextSize) {
    fprintf(stderr, "CLIENT: ERROR key '%s' is too short\n", argv[2]);
    exit(1);
  }
  
  // create socket
  socketFD = socket(AF_INET, SOCK_STREAM, 0); 
  if (socketFD < 0) {
    error("CLIENT: ERROR opening socket");
  }
  setupAddressStruct(&serverAddress, atoi(argv[3]), "localhost");

  // connect to server
  if (connect(socketFD, (struct sockaddr*)&serverAddress, sizeof(serverAddress)) < 0) {
    error("CLIENT: ERROR connecting");
  }

  memset(buffer, '\0', BUFFER_SIZE); // clear buffer
  recv(socketFD, buffer, BUFFER_SIZE - 1, 0); // recieve handshake from server

  // check if server is enc_server
  if (strcmp(buffer, "enc_server") != 0) {
    fprintf(stderr, "CLIENT: ERROR Invalid Server on port %s", argv[3]);
    close(socketFD);
    exit(2);
  }

  // send plaintext size to server
  windowSize = htonl((int)plaintextSize);
  if (send(socketFD, &windowSize, sizeof(windowSize), 0) < 0) {
    error("CLIENT: ERROR sending plaintext size");
  }
  
  // send plaintext data to server in chunks (1024 bytes) 
  totalSent = 0;
  while (totalSent < plaintextSize) {
    remainingBytes = plaintextSize - totalSent;
    if (remainingBytes > BUFFER_SIZE) {
        messageSize = BUFFER_SIZE;
    } else {
        messageSize = remainingBytes;
    }
    bytesSent = send(socketFD, plaintext + totalSent, messageSize, 0);
    totalSent += bytesSent;
  }

  memset(buffer, '\0', BUFFER_SIZE);
  if (recv(socketFD, buffer, BUFFER_SIZE - 1, 0) < 0) { // recieve "ack" from server
    error("CLIENT: ERROR reading ack from socket");
  }
  windowSize = htonl((int)keySize);

  // send key size to server
  if (send(socketFD, &windowSize, sizeof(windowSize), 0) < 0) {
    error("CLIENT: ERROR sending key size");
  }
  
  // send key data to server in chunks (1024 bytes)
  totalSent = 0;
  while (totalSent < keySize) {
    remainingBytes = keySize - totalSent;
    if (remainingBytes > BUFFER_SIZE) {
      messageSize = BUFFER_SIZE;
    } else {
      messageSize = remainingBytes;
    }
    bytesSent = send(socketFD, key + totalSent, messageSize, 0);
    if (bytesSent < 0) {
      error("CLIENT: ERROR writing key to socket");
    }
    totalSent += bytesSent;
  }

  memset(buffer, '\0', BUFFER_SIZE);
  if (recv(socketFD, buffer, BUFFER_SIZE - 1, 0) < 0) { // recieve "ack" from server
    error("CLIENT: ERROR reading ack from socket");
  }

  // recieve encrypted data size from server
  if (recv(socketFD, &encryptedSize, sizeof(encryptedSize), 0) < 0) {
    error("CLIENT: ERROR reading encrypted size from socket");
  }
  encryptedSize = ntohl(encryptedSize);
  encryptedData = malloc(encryptedSize + 1); // allocate memory for encrypted data

  if (encryptedData == NULL) {
    error("CLIENT: ERROR allocating memory for encrypted data");
  }
  memset(encryptedData, '\0', encryptedSize + 1);
  
  // recieve encrypted data from server in chunks (1024 bytes)
  totalReceived = 0;
  while (totalReceived < encryptedSize) { 
    bytesReceived = recv(socketFD, encryptedData + totalReceived, encryptedSize - totalReceived, 0);
    
    if (bytesReceived < 0) {
      error("CLIENT: ERROR reading encrypted data from socket");
    }
    if (bytesReceived == 0) {
      break; 
    }
    totalReceived += bytesReceived;
  }
  
  printf("%s", encryptedData); // print encrypted data to stdout
  // free memory & close connection
  free(plaintext);
  free(key);
  free(encryptedData);
  close(socketFD);
  return 0;
}