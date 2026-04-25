# 📦 Logger (Roblox)

<p align="center">
  <img src="https://img.shields.io/badge/Roblox-Library-red?style=for-the-badge&logo=roblox">
  <img src="https://img.shields.io/badge/Webhooks-Discord-blue?style=for-the-badge&logo=discord">
  <img src="https://img.shields.io/badge/Status-Stable-green?style=for-the-badge">
  <img src="https://img.shields.io/badge/License-Protected-orange?style=for-the-badge">
</p>

---

## 📖 Introduction

**Logger** is an advanced logging system for **Roblox**, designed to enhance the **Developer Console** with Colored logs, Custom Icons, DYnamic progress bar, etc!

---

## 📑 Table of Contents

-   Installation
-   Basic Usage
-   Log Types
-   Documentation
-   Loading System
-   Settings
-   Important Notes
-   License

---

## ⚙️ Installation

``` lua
local Logger = loadstring(game:HttpGet("https://raw.githubusercontent.com/00lxh/roblox-logger/refs/heads/main/logger.lua"))();
```

---

## 🚀 Basic Usage

``` lua

local Logger = loadstring(game:HttpGet("https://raw.githubusercontent.com/00lxh/roblox-logger/refs/heads/main/logger.lua"))();

Logger.info("Game started");
Logger.success("Player joined");
Logger.warn("Low memory warning");
Logger.error("Something failed");
```

---

## 📂 Log Types

-   EVENT
-   WARN
-   ERROR
-   SUCCESS
-   DEBUG
-   INFO
-   WAITING
-   READY
-   LOADING

---

## 📚 Documentation

### Logger.info

``` lua
Logger.info("Message");
```

### Logger.warn

``` lua
Logger.warn("Warning message");
```

### Logger.error

``` lua
Logger.error("Error message");
```

### Logger.success

``` lua
Logger.success("Success message");
```

### Logger.debug

``` lua
Logger.debug("Debug message");
```

### Logger.event

``` lua
Logger.event("Event triggered");
```

### Logger.wait

``` lua
Logger.wait("Waiting...");
```

### Logger.ready

``` lua
Logger.ready("Ready!");
```

---

## ⏳ Loading System

``` lua
local loader = Logger:CreateLoading({
    Title = "LOADING",
    Subject = "Game Assets",
    TotalSteps = 10
});

loader:SetCurrentStep(5);
```

---

## ⚙️ Settings

``` lua
Logger:ToggleIcons(true);
Logger:ToggleConsoleLogs(true);
Logger:ToggleLogs(true);
Logger:SetSaveLocation("logs");
```

---

## ⚠️ Important Notes

-   Requires http support
-   Requires file system support

---

## 📜 License

IMPORTANT

- Do not redistribute without credit
- No commercial use without permission
- Must keep attribution
