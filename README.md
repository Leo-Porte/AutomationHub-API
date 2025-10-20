# AutomationHub-API
An intelligent automation API built with .NET 8 to connect ChatGPT, GitHub, and Jira. Serves as the local brain for the DevFlow Hub ecosystem, enabling contextual AI interaction, workflow automation, and smart development planning.

# 🚀 AutomationHub (API)

[![.NET 8](https://img.shields.io/badge/.NET-8.0-blueviolet?logo=dotnet)](https://dotnet.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![OpenAI](https://img.shields.io/badge/Powered%20by-OpenAI-00A67E?logo=openai)](https://openai.com/)
[![Build](https://img.shields.io/badge/Build-Passing-brightgreen)](#)

---

## 🧠 Overview

**AutomationHub** is a modular automation API built with **.NET 8**, designed to serve as the **local brain** for the **DevFlow Hub ecosystem**.  
It connects **ChatGPT**, **GitHub**, and **Jira** to enable smart, contextual automation of your development workflow — entirely under your control and running locally.

This API is the foundation for an intelligent environment where your assistant (ChatGPT) understands your code, tracks tasks, and helps you plan and execute development more efficiently.

---

## ⚙️ Features

- 💬 **ChatGPT Integration** – Connects to the OpenAI API for contextual, intelligent responses.
- 🧠 **Local AI Processing** – Keeps your workflow private, efficient, and cost-effective.
- 🔗 **Planned Integrations** – GitHub (Octokit) and Jira (REST API).
- 🧩 **Extensible Modular Architecture** – Add new services without changing the core.
- 🧾 **Clean .NET 8 Structure** – Built following best practices for scalability and maintainability.

---

## 🧱 Tech Stack

| Component | Technology |
|------------|-------------|
| Backend | .NET 8 (ASP.NET Core Web API) |
| Language | C# 12 |
| AI Integration | OpenAI SDK for .NET |
| Documentation | Swagger UI |
| Future Data Layer | SQLite or LiteDB |
| Auth & Config | appsettings.json (securely ignored via .gitignore) |

---

## 🚀 Getting Started

### 1️⃣ Clone the repository

```bash
git clone https://github.com/Leo-Porte/AutomationHub.git
cd AutomationHub
```

### 2️⃣ Install dependencies

```bash
dotnet restore
```

### 3️⃣ Configure OpenAI API Key

```bash
Create a file named appsettings.Development.json (not committed to Git) with:

{
  "OpenAI": {
    "ApiKey": "INSERT_YOUR_API_KEY_HERE"
  }
}
```

### 4️⃣ Run the API

```bash
dotnet run
```

Then navigate to:
👉 https://localhost:7100/swagger

### 🧩 API Endpoints

Method	Endpoint	Description
```bash
POST	/api/chat/send	Sends a message to ChatGPT and returns a response.
GET	/api/github/status	(Coming soon) Repository sync and status check.
GET	/api/jira/issues	(Coming soon) Retrieve Jira issues and progress.
```

🧭 Roadmap:
```bash
 Base Web API with OpenAI Integration

 - Context caching and memory persistence ✅

 - GitHub Integration (Octokit) ❌

 - Jira Integration (REST API) ❌

 - MAUI App client connection ❌

 - Smart AI-driven task planning ❌
```

### 🧑‍💻 Contributing

Contributions are welcome!
Please fork the repository and open a pull request with improvements, bug fixes, or new features.

⚖️ License
This project is licensed under the MIT License.

## 🔧 SonarQube Environment Setup

This project uses a local SonarQube instance running in Docker (image: `sonarqube:lts-community`). The `analyze.ps1` script automates the entire analysis process.

### Requirements
- Docker Desktop installed and running
- .NET 8 SDK installed
- dotnet-sonarscanner global tool:

```
dotnet tool install --global dotnet-sonarscanner
```

### Create local secrets
Create a `secrets.ps1` file at the project root with your token:

```
$Token = "sqp_SEU_TOKEN_AQUI"
```

The file is already listed in `.gitignore` and will not be committed.

### Run the analysis
Execute the PowerShell script from the repository root:

```
powershell -ExecutionPolicy Bypass -File .\analyze.ps1
```

The script will:
- Ensure the Docker container `sonarqube` using the `sonarqube:lts-community` image exists and is running
- Wait until the server health is GREEN
- Run the sequence: `begin → build → end`
- Open the SonarQube dashboard automatically

### Check the dashboard
Open:
- http://localhost:9000

First login (default credentials):
- user: admin
- password: admin

Change the password after the first login.

### Best practices
- Never commit tokens or sensitive local files
- Update `secrets.ps1` only locally
- Reuse this flow later to store other keys (Jira, GitHub, etc.)

