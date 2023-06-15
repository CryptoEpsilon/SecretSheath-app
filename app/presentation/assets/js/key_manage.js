const shareButton = document.querySelector("#share-button");
const feedback = document.querySelector('#feedback')
const accessor_input = document.querySelector("#accessor-email-input");
const accessorTable = document.querySelector("#accessor-table");

shareButton.addEventListener('click', () => {
  accessor_email = accessor_input.value;
  action = document.querySelector("#add-accessor").value;
  url = shareKeyForm.action;

  const xhr = new XMLHttpRequest();
  xhr.open('POST', url, true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send(JSON.stringify({ "email": accessor_email, "action": action }));

  xhr.onload = () => {
    if (xhr.status === 200) {
      response = JSON.parse(xhr.responseText)['data'];

      accessor_name = response['relationships']['accessor'][0]['attributes']['username']
      accessor_email = response['relationships']['accessor'][0]['attributes']['email']
      childkey_name = response['attributes']['name']
      childkey_alias = response['attributes']['alias']
      short_alias = response['attributes']['short_alias']
      send_to_url = shareKeyForm.getAttribute('action')
      
      let row = accessorTableBody.insertRow()
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
      action_field.innerHTML = `
      <form action="${send_to_url}" method="post" role="form">
          <input type="hidden" name="_method" value="delete">
          <input type="hidden" name="email" value="${accessor_email}">
          <button class="btn btn-light fas fa-trash-alt" type="button">
          </button>
      </form>
      `

      shareKeyForm.reset();
      feedback.classList.remove('invalid-feedback')
      accessor_input.classList.remove("is-invalid")
      
      accessor_input.classList.add("is-valid")
      feedback.classList.add('valid-feedback')
      feedback.innerHTML = `Added user '${accessor_name}' as accessor successfully.`
      
    } else {
      feedback.classList.remove('valid-feedback')
      accessor_input.classList.remove("is-valid")
      
      accessor_input.classList.add("is-invalid")
      feedback.classList.add('invalid-feedback')
      feedback.innerHTML = "Error adding accessor."
    }
  }
});

accessorTable.addEventListener('click', (e) => {
  shareKeyForm.reset();
  accessor_input.classList.remove("is-invalid")
  accessor_input.classList.remove("is-valid")
  feedback.innerHTML = "";

  target = e.target;
  delete_accessor_form = target.parentElement;
  url = target.parentElement.action;
  action = target.parentElement._method.value;
  accessor_email = target.parentElement.email.value;

  const xhr = new XMLHttpRequest();
  xhr.open('POST', url, true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send(JSON.stringify({ "email": accessor_email, "action": action }));
  xhr.onload = () => {
    if (xhr.status === 200) {
      response = JSON.parse(xhr.responseText)['data'];
      short_alias = response['attributes']['short_alias']
      
      document.getElementById(short_alias).remove()
    } else {
      console.log("Error deleting accessor.")
    }
  }
});