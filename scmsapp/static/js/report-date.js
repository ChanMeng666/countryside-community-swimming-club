$(document).ready(function() {
    $('#date_from').on('change', function() {
        $('#date_to').attr('min', $(this).val());
    });
    $('#date_to').on('change', function() {
    });
});
