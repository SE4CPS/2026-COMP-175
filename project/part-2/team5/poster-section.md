# Clinical web interface — Team 5 poster section

**Purpose:** Let a user select a synthetic hospital persona and see what that account can actually read on the clinical Ubuntu server.

**How it works:** A Flask dashboard on Kali sends read-only SSH requests. A forced command on Ubuntu runs under the selected Linux persona. Ubuntu's real file permissions decide whether a record read succeeds. The page displays the command's actual output or error. A separate Team 5 operator login handles deployment and restart of the web app.

**Component result:** On our isolated VM pair, the synthetic record read succeeded; a root-only test file returned `Permission denied`; all four persona identities resolved; six automated tests passed. The shared Team 4 RBAC and class-network test are next.

**Boundary:** No direct write operation exists for clinical records. The dashboard uses only synthetic course data. AI assistance: Codex helped implement, test, and document the component.
