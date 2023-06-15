const decrypt_form = document.querySelector('#decrypt-data-form');
const decrypt_button = document.querySelector("#decryption-form-submit");

decrypt_button.addEventListener('click', () => {
    ciphertext_input = document.querySelector("#ciphertext_input");
    ciphertext = ciphertext_input.value.trim();

    url = decrypt_form.action;
    const xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({ "ciphertext": ciphertext }));

    output = cipherOutModal.getElementsByTagName('pre')[0];

    xhr.onload = () => {
        if (xhr.status === 200) {
            response = JSON.parse(xhr.responseText);
            output.innerText = response.data.attributes.plaintext
            ciphertext_input.classList.remove('is-invalid');
        } else if (xhr.status === 400) {
            output.innerText = 'Your ciphertext is invalid. \nIt\'s either expired or you entered the incorrect value.'
            ciphertext_input.classList.add('is-invalid');
        } else {
            output.innerText = 'Sorry, something went wrong. Please try again later.'
            ciphertext_input.classList.add('is-invalid');
        }
    };
});