const form = document.querySelector('#excuse-form');
const status = document.querySelector('#status');
const result = document.querySelector('#result');
const idea = document.querySelector('#idea');
const regenerate = document.querySelector('#regenerate');
const submit = form.querySelector('[type="submit"]');

async function generate() {
  if (!form.checkValidity()) {
    form.reportValidity();
    return;
  }
  status.textContent = 'Generating idea...';
  result.hidden = true;
  submit.disabled = true;
  regenerate.disabled = true;
  try {
    const response = await fetch('/api/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(Object.fromEntries(new FormData(form)))
    });
    const payload = await response.json();
    if (!response.ok) throw new Error(payload.error || 'Unable to generate an idea.');
    idea.textContent = payload.idea;
    result.hidden = false;
    regenerate.hidden = false;
    status.textContent = '';
  } catch (error) {
    status.textContent = error.message || 'Unable to generate an idea. Try again.';
  } finally {
    submit.disabled = false;
    regenerate.disabled = false;
  }
}

form.addEventListener('submit', (event) => {
  event.preventDefault();
  generate();
});
regenerate.addEventListener('click', generate);
