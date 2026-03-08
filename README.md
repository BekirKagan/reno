# reno

A lightweight Windows utility that checks for available updates via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) at every login and surfaces them as a native toast notification with a one-click **Update** button.

![Windows 10/11](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows)
![PowerShell 7+](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell)

---

## How it works

1. At every login, `reno.ps1` runs silently in the background via Task Scheduler.
2. It calls `winget upgrade --include-unknown` and collects any available updates.
3. If updates are found, a toast notification appears listing them.
4. Clicking the **Update** button runs `reno-update.ps1`, which installs all available updates and shows a follow-up toast with the result.

---

## Prerequisites

- Windows 10 or 11
- [PowerShell 7+](https://aka.ms/powershell)
- [winget](https://aka.ms/getwinget) (App Installer from the Microsoft Store)
- [BurntToast](https://github.com/Windos/BurntToast) PowerShell module

To install BurntToast, run:

```powershell
Install-Module -Name BurntToast -Scope CurrentUser
```

---

## Installation

1. Clone or download this repository to a permanent location. **Do not move the folder after setup**, as the scripts are registered by their path.

```powershell
git clone https://github.com/BekirKagan/reno.git
```

2. Run `reno-setup.ps1`. It will prompt for administrator permissions via UAC.

```powershell
pwsh -File reno-setup.ps1
```

That's it. Reno will run automatically at every login from now on.

---

## Scripts

| Script | Description |
|---|---|
| `reno.ps1` | Checks for updates and shows the toast notification. Runs at login via Task Scheduler. |
| `reno-update.ps1` | Runs `winget upgrade --all --include-unknown`. Triggered by the Update button on the toast. |
| `reno-setup.ps1` | Registers the Task Scheduler task and sets up reno. Run once after cloning. Requires admin. |
| `reno-uninstall.ps1` | Removes the Task Scheduler task and the protocol handler. Fully uninstalls reno. Requires admin. |

---

## Uninstallation

Run `reno-uninstall.ps1`. It will prompt for administrator permissions via UAC and clean up everything reno has registered on your machine.

```powershell
pwsh -File reno-uninstall.ps1
```

---

## Security

Reno registers a custom URI protocol handler (`reno://`) in your Windows registry under `HKCU\Software\Classes`. This is how the **Update** button on the toast notification works — the same pattern used by apps like Spotify (`spotify://`), VS Code (`vscode://`), and Steam (`steam://`).

Things you should know:

- The handler is **persistent** — it stays in the registry after the script finishes. Running `reno-uninstall.ps1` removes it completely.
- The handler runs with your **normal user account permissions**. No elevated rights are used at runtime.
- `reno-setup.ps1` and `reno-uninstall.ps1` require **administrator permissions** only for registering and unregistering the Task Scheduler task.
- **Do not move the repository folder** after running setup. The registered task and protocol handler both point to the scripts at their original path. If you need to move it, run `reno-uninstall.ps1` first, move the folder, then run `reno-setup.ps1` again.

---

## License

[MIT](LICENSE)
