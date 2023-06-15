const keyTable = document.querySelector('#key-table');
let accessorTableBody = document.querySelector("#accessor-table-body")

const keyModal = document.querySelector('#keyModal');
const cipherOutModal = document.querySelector("#cipherOutput");

const encryptForm = document.querySelector("#encrypt-data-form");
const decryptForm = document.querySelector("#decrypt-data-form");
const deleteKeyForm = document.querySelector("#delete-key-form");
const shareKeyForm = document.querySelector("#share-key-form");

const copyButton = document.querySelector("#copy-button");

const encryptPill = document.querySelector("#encrypt-pill");
const decryptPill = document.querySelector("#decrypt-pill");
const managePill = document.querySelector("#manage-pill");

const encryptTab = document.querySelector("#Encrypt");
const decryptTab = document.querySelector("#Decrypt");

keyTable.addEventListener('click', (e) => {
    e.preventDefault();
    target = e.target;
    key_link = target.getAttribute('href');
    accessorTableBody = document.querySelector("#accessor-table-body")

    const xhr = new XMLHttpRequest();
    xhr.open('GET', key_link, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send();
    xhr.onload = () => {
        if (xhr.status === 200) {
            response = JSON.parse(xhr.responseText)['data'];

            if (!response['policies']['can_encrypt']) {
                encryptPill.style.display = "none";

                decryptPill.classList.add("active");
                decryptTab.classList.add("active");
                decryptTab.classList.add("show");

                encryptTab.classList.remove("active");
                encryptTab.classList.remove("show");
            } else {
                encryptPill.style.display = "block";

            }
            !response['policies']['can_manage'] ? managePill.style.display = "none" : managePill.style.display = "block";
            !response['policies']['can_add_accessors'] ? shareKeyForm.style.display = "none" : shareKeyForm.style.display = "block";
            !response['policies']['can_delete'] ? deleteKeyForm.style.display = "none" : deleteKeyForm.style.display = "block";

            key_name = response['attributes']['name'];
            key_alias = response['attributes']['alias'];
            folder_name = response['include']['folder']['attributes']['name'];
            header_html = key_name + `<br><small class="text-muted">${key_alias}</small>`;
        
            const modal_header = keyModal.getElementsByClassName('modal-header')[0];
            const h4 = modal_header.getElementsByTagName('h4')[0];
            h4.innerHTML = header_html;
        
            const cipher_out_header = cipherOutModal.getElementsByTagName('h4')[0];
            cipher_out_header.innerHTML = header_html;
            
            encryptForm.action = `/encrypt/${folder_name}/${key_alias}`;
            decryptForm.action = `/decrypt/${folder_name}/${key_alias}`;
            deleteKeyForm.action = key_link;
            shareKeyForm.action = `${key_link}/accessors`;

            childkeys = response['relationships']['children'];
            for ( c in childkeys ) {
                accessor_name = childkeys[c]['relationships']['accessor'][0]['attributes']['username']
                accessor_email = childkeys[c]['relationships']['accessor'][0]['attributes']['email']
                childkey_name = childkeys[c]['attributes']['name']
                childkey_alias = childkeys[c]['attributes']['alias']
                short_alias = childkeys[c]['attributes']['short_alias']
                send_to_url = shareKeyForm.getAttribute('action')
                
                row = accessorTableBody.insertRow()
                row.setAttribute("id", short_alias)
                // row.classList.add("text-center")

                accessor_field = row.insertCell(0)
                accessor_field.innerHTML = accessor_name

                email_field = row.insertCell(1)
                email_field.innerHTML = accessor_email

                childkey_field = row.insertCell(2)
                childkey_field.innerHTML = childkey_name

                alias_field = row.insertCell(3)
                alias_field.innerHTML = childkey_alias

                action_field = row.insertCell(4)
                if (response['policies']['can_remove_accessors']) {    
                    action_field.innerHTML = `
                    <form action="${send_to_url}" method="post" role="form">
                        <input type="hidden" name="_method" value="delete">
                        <input type="hidden" name="email" value="${accessor_email}">
                        <button class="btn btn-light fas fa-trash-alt" type="button">
                        </button>
                    </form>
                    `
                }
            }
            
        }
    }

});

copyButton.addEventListener('click', () => {
    const copyButtonLabel = copyButton.innerHTML;
    copiedText = cipherOutModal.getElementsByTagName('pre')[0].innerText;
    navigator.clipboard.writeText(copiedText);

    copyButton.innerHTML = '<i class="fas fa-circle-check"></i> Copied!';
    copyButton.classList.add('btn-outline-success');

    setTimeout(() => {
        copyButton.innerHTML = copyButtonLabel;
        copyButton.classList.remove('btn-outline-success');
    }, 1000);
});

keyModal.addEventListener('hidden.bs.modal', () => {
    encryptForm.reset();
    decryptForm.reset();

    shareKeyForm.reset();
    accessor_input.classList.remove("is-invalid")
    accessor_input.classList.remove("is-valid")
    feedback.innerHTML = "";

    let resetTable = document.createElement('tbody');
    resetTable.setAttribute('id', 'accessor-table-body');
    accessorTableBody.parentNode.replaceChild(resetTable, accessorTableBody);
});

decryptPill.addEventListener('shown.bs.tab', () => {
    decryptForm.reset();
    cipherOutModal.getElementsByTagName('pre')[0].innerText = "";
});

managePill.addEventListener('hide.bs.tab', () => {
    shareKeyForm.reset();
    accessor_input.classList.remove("is-invalid")
    accessor_input.classList.remove("is-valid")
    feedback.innerHTML = "";
});