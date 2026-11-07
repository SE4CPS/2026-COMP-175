const buttons = document.querySelectorAll(".buttons button");
const result = document.querySelector("#result");

for (const button of buttons) {
  button.addEventListener("click", async () => {
    for (const actionButton of buttons) actionButton.disabled = true;
    result.textContent = `Running ${button.textContent.trim()}…`;

    try {
      const response = await fetch(button.dataset.url, {
        method: "POST",
        headers: { "X-Button-Panel": "1" },
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      result.textContent = data.message;
    } catch {
      result.textContent = "The action failed. Check the terminal running Flask for details.";
    } finally {
      for (const actionButton of buttons) actionButton.disabled = false;
      button.focus();
    }
  });
}
