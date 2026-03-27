const runsEl = document.getElementById("runs");
const trialBtn = document.getElementById("trial");

let runs = 24810;
setInterval(() => {
  runs += Math.floor(Math.random() * 3);
  runsEl.textContent = runs.toLocaleString();
}, 2500);

trialBtn?.addEventListener("click", () => {
  window.location.href = "https://api.nestra.homelabdev.space/v1/status";
});
