// This code keeps the index vertically attached to the window
// which means that a user can scroll down a long song, then
// swipe left to find the index page (instead of having to scroll back up)
window.addEventListener('scroll', function() {
  document.querySelector('.song-index').style.top = `${window.pageYOffset}px`;
});
