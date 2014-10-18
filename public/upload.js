var guid = (function () {
  var s4 = function () {
    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  }
  return function () {
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
           s4() + '-' + s4() + s4() + s4();
  };
})();

var resetMessages = function () {
  $('.error').css('display', 'none');
  $('.warning').css('display', 'none');
  $('.success').css('display', 'none');
};

var showSuccess = function (success) {
  resetMessages();
  $('.success').css('display', 'block');
  $('.success')[0].innerHTML = success;
};

var showWarning = function (warning) {
  resetMessages();
  $('.warning').css('display', 'block');
  $('.warning')[0].innerHTML = warning;
};

var showError = function (error) {
  resetMessages();
  $('.error').css('display', 'block');
  $('.error')[0].innerHTML = '<b>Error:</b> ' + error;
};

var updateViewUploadStatus = function (data) {
  showWarning('Uploading: ' + data.percent + '%');
};

$(document).ready(function () {
  $('#upload').submit(function (event) {
    $('#submit').prop('disabled', true);
    resetMessages();
    event.stopImmediatePropagation();
    event.preventDefault();

    var formData = new FormData();
    var fileSelect = document.getElementById('file');
    var name = document.getElementById('name').value;
    if (name.length == 0 || fileSelect.files.length == 0){
      $('#submit').prop('disabled', false);
      return showError('Name and file are both required.');
    }

    var file = fileSelect.files[0];
    if (file) formData.append('file', file, file.name);


    var done = false;
    var xProgressID = guid();

    var xhr = new XMLHttpRequest();
    var url = '/upload?X-Progress-ID=' + xProgressID + '&name=' + name;
    xhr.open('POST', url, true);
    xhr.send(formData);
    xhr.onreadystatechange = function () {
      done = true;
      $('#submit').prop('disabled', false);
      if (xhr.status != 201) {
        var responseJSON = JSON.parse(xhr.responseText);
        showError(responseJSON.error);
        console.log(responseJSON);
      } else {
        showSuccess('File Uploaded!');
      }
    };

    var uploadIntervalID = setInterval(function(){
        $.get('/progress?X-Progress-ID=' + xProgressID, function(data){
            if (data.status === 'starting' || data.progress === 100){
                clearInterval(uploadIntervalID);
            } else {
              updateViewUploadStatus(data);
            }
        }).error(function () {
          if (done) clearInterval(uploadIntervalID);
        });
    }, 250);
    return false;
  });
});
