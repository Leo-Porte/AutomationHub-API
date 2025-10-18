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

### 2️⃣ Install dependencies
dotnet restore

### 3️⃣ Configure OpenAI API Key

Create a file named appsettings.Development.json (not committed to Git) with:

{
  "OpenAI": {
    "ApiKey": "INSERT_YOUR_API_KEY_HERE"
  }
}

### 4️⃣ Run the API
dotnet run


Then navigate to:
👉 https://localhost:7100/swagger

