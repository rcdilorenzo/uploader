window.paceOptions = {
  ajax: true
};

$(document).ready(function () {
  $('#upload').submit(function (event) {
    var formData = new FormData();
    var fileSelect = document.getElementById('file');
    var name = document.getElementById('name').value;

    var file = fileSelect.files[0];
    if (file) formData.append('file', file, file.name);

    $('.error').css('display', 'none');
    $('.success').css('display', 'none');

    Pace.track(function () {
      var xhr = new XMLHttpRequest();
      var url = '/upload?name=' + name;
      xhr.open('POST', url, true);
      xhr.send(formData);
      xhr.onreadystatechange = function () {
        if (xhr.status != 201) {
          var responseJSON = JSON.parse(xhr.responseText);
          $('.error').css('display', 'block');
          $('.error')[0].innerHTML = '<b>Error:</b> ' + responseJSON.error;
          console.log(responseJSON);
        } else {
          $('.success').css('display', 'block');
          $('.success')[0].innerHTML = 'File uploaded!';
        }
      };
    });
    event.preventDefault();
  });
});
