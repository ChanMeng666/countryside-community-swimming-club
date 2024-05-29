$(document).ready(function() {
    // Function to toggle readonly attribute of form fields
    function toggleReadOnly(status) {
        $('.editable').prop('readonly', status);
        $('.selectable').prop('disabled', status);
    }

    // Function to toggle edit and submit buttons
    function toggleButtons() {
        $('#editBtn').toggle();
        $('#submitBtn').toggle();
        $('#cancelBtn').toggle();
        $('.ondemand').toggle();
    }

    // Add event listener to the edit button
    $('#editBtn').click(function() {
        toggleReadOnly(false); // Make editable
        toggleButtons(); // Show submit and cancel buttons, hide edit button
        $('.editable').toggleClass("form-control-plaintext", false);
        $('.editable').toggleClass("form-control", true);
    });

    // Add event listener to the cancel button
    $('#cancelBtn').click(function() {
        toggleReadOnly(true); // Make readonly
        toggleButtons(); // Show edit button, hide submit button
        $('.editable').toggleClass("form-control-plaintext", true);
        $('.editable').toggleClass("form-control", false);
    });
    // Initially make form readonly and show edit button
    toggleReadOnly(true);

    // Validate file format
    $('#user_profile_form').submit(function() {
        var allowedFormats = ['jpg', 'jpeg', 'png', 'gif'];
        var fileName = $('#upload_image').val().toLowerCase();
        if (!fileName) {
            return true;
        }
        var extension = fileName.substring(fileName.lastIndexOf('.') + 1);
        if ($.inArray(extension, allowedFormats) === -1) {
            alert('Invalid file format. Please upload an image with one of the following formats: ' + allowedFormats.join(', '));
            return false; // Prevent form submission
        }
        return true; // Allow form submission
    });
});
