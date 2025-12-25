# Voting App

A simple distributed application running across multiple Docker containers.

<img width="860" height="800" alt="image" src="https://github.com/user-attachments/assets/07df71e7-21eb-4b9b-b75d-d5ad00d858bb" />

* A front-end web app in Python which lets you vote between two options
* A Redis which collects new votes
* A .NET worker which consumes votes and stores them in…
* A Postgres database backed by a Docker volume
* A Node.js web app which shows the results of the voting in real time


