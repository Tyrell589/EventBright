$(document).ready(function () {
  const replyBtns = Array.from(document.querySelectorAll(".reply-btn"));
  const cancelBtns = Array.from(document.querySelectorAll(".cancel-btn"));

  replyBtns.forEach((btn) => btn.addEventListener("click", displayReplyForm));
  cancelBtns.forEach((btn) => btn.addEventListener("click", hideReplyForm));

  function displayReplyForm(e) {
    const formId = e.target.id
    const replyForm = document.getElementById(`reply-form-${formId}`)
    replyForm.style.display = "block";
  }

  function hideReplyForm(e) {
    const formId = e.target.id
    const replyForm = document.getElementById(`reply-form-${formId}`)
    replyForm.style.display = "none";
  }
});

