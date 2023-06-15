const encrypt_form = document.querySelector('#encrypt-data-form');
const encrypt_button = document.querySelector("#encryption-form-submit");

encrypt_button.addEventListener('click', () => {
    plaintext_input = document.querySelector("#plaintext_input");
    plaintext = plaintext_input.value;

    expire_in_radio = document.getElementsByName('expire_in');
    expire_in_value = Array.from(expire_in_radio).find(radio => radio.checked).value

    url = encrypt_form.action;
    const xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({ "plaintext": plaintext, "expire_in": expire_in_value }));

    output = cipherOutModal.getElementsByTagName('pre')[0];
    output.innerText = 'Encrypting...'

    xhr.onload = () => {
            if (xhr.status === 200) {
                response = JSON.parse(xhr.responseText);
                output.innerText = response.data.attributes.ciphertext
                plaintext_input.classList.remove('is-invalid');
            } else {
                output.innerText = 'Sorry, something went wrong. Please try again later.'
                plaintext_input.classList.add('is-invalid');
            }
        };
});