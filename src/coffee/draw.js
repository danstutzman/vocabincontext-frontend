var canvas, ctx, flag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0,
    dot_flag = false;

var x = "black",
    lineWidth = 10;

function initDraw() {

    canvas.addEventListener("mousemove", function (e) { findxy('move', e) }, false);
    canvas.addEventListener("mousedown", function (e) { findxy('down', e) }, false);
    canvas.addEventListener("mouseup", function (e) { findxy('up', e) }, false);
    canvas.addEventListener("mouseout", function (e) { findxy('out', e) }, false);
    canvas.addEventListener("touchstart", function (e) { findxy('down', e) }, false);
    canvas.addEventListener("touchmove", function (e) { findxy2('move', e); }, false);
}

function draw() {
    ctx.beginPath();
    ctx.moveTo(prevX, prevY);
    ctx.lineTo(currX, currY);
    ctx.strokeStyle = x;
    ctx.lineWidth = lineWidth;
    ctx.stroke();
    ctx.closePath();

    draw_circle();
}

function draw_circle() {
    ctx.beginPath();
    ctx.arc(currX, currY, lineWidth / 2, 0, 2 * Math.PI, false);
    ctx.fillStyle = x;
    ctx.fill();
}

function findxy2(res, e) {
  canvas = e.target;
  ctx = canvas.getContext("2d");

  var rect = canvas.getBoundingClientRect();
  if (res == 'down') {
    currX = e.touches[0].pageX - rect.left - document.body.scrollLeft;
    currY = e.touches[0].pageY - rect.top - document.body.scrollTop;
    draw_circle();
  } else if (res == 'move') {
    prevX = currX;
    prevY = currY;
    currX = e.touches[0].pageX - rect.left - document.body.scrollLeft;
    currY = e.touches[0].pageY - rect.top - document.body.scrollTop;

    draw();
  }

  e.preventDefault();
}

function findxy(res, e) {
    //canvas = document.getElementById('can');
    canvas = e.target;
    ctx = canvas.getContext("2d");

    if (res == 'down') {
        prevX = currX;
        prevY = currY;
        var rect = canvas.getBoundingClientRect();
        currX = e.pageX - rect.left - document.body.scrollLeft;
        currY = e.pageY - rect.top - document.body.scrollTop;

        flag = true;
        dot_flag = true;
        if (dot_flag) {
            ctx.beginPath();
            ctx.fillStyle = x;
            ctx.fillRect(currX, currY, 2, 2);
            ctx.closePath();
            dot_flag = false;
        }

        draw_circle();
    }
    if (res == 'up' || res == "out") {
        flag = false;
    }
    if (res == 'move') {
        if (flag) {
            prevX = currX;
            prevY = currY;
            //currX = e.pageX - canvas.offsetLeft;
            //currY = e.pageY - canvas.offsetTop;
            var rect = canvas.getBoundingClientRect();
            currX = e.pageX - rect.left - document.body.scrollLeft;
            currY = e.pageY - rect.top - document.body.scrollTop;
            draw();
        }
    }

    e.preventDefault();
}

module.exports = {
  initDraw: initDraw,
  draw:     draw,
  findxy:   findxy,
  findxy2:  findxy2
};
