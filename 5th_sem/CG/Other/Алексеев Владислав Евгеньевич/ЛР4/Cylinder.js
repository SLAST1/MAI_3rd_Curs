var camera, scene, renderer, controls, geom, mesh, light;

function init() {
    // Возьмем наш контейнер
    var container = document.getElementById("container");
    const approx = document.getElementById("approx");
    const intens = document.getElementById("intens");

    // Создадим рендерер Three.js и добавим его в наш контейнер
    renderer = new THREE.WebGLRenderer();
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(container.offsetWidth, container.offsetHeight);
    container.appendChild(renderer.domElement);

    // Создадим сцену Three.js
    scene = new THREE.Scene();

    // Создадим камеру и добавим ее в сцену
    camera = new THREE.PerspectiveCamera(45, container.offsetWidth / container.offsetHeight, 1, 500);
    camera.position.set(0, 0, 150);
    scene.add(camera);

    controls = new THREE.OrbitControls(camera, renderer.domElement);
    // При включении перемещения или автоповорота требуется цикл анимации
    controls.enableDamping = true;
    controls.dampingFactor = 0.25;

    controls.screenSpacePanning = false;
    controls.minDistance = 100;
    controls.maxDistance = 400;

    scene.add(new THREE.HemisphereLight(0x606060, 0x404040));

    light = new THREE.DirectionalLight(0xffffff);
    light.intensity = intens.value;
    light.reflectivity = intens.value;
    light.position.set(600, 600, 600).normalize();
    scene.add(light);

    geom = initGeom();

    var blue = new THREE.Color("rgb(0, 255, 255)");
    var material = new THREE.MeshLambertMaterial({ color: blue });

    mesh = new THREE.Mesh(geom, material);

    scene.add(mesh);
}

const A = 20, B = 10, H = 60;
let num = approx.value;

approx.onchange = function (e) {
    num = approx.value;

    scene.remove(mesh);
    geom = initGeom();

    var blue = new THREE.Color("rgb(0, 255, 255)");
    var material = new THREE.MeshLambertMaterial({ color: blue });

    mesh = new THREE.Mesh(geom, material);

    scene.add(mesh);
    render();
}

intens.onchange = function(e) {
    light.intensity = intens.value;
}

function fplus(x) {
    return Math.sqrt((1 - (x * x) / (A * A)) * B * B);
}

function fminus(x) {
    return -Math.sqrt((1 - (x * x) / (A * A)) * B * B);
}

function initGeom() {
    // Аппроксимируем выпуклое тело треугольниками
    var geometry = new THREE.BufferGeometry();
    var vertices = [];

    var step = 2 * A / num;
    // Лицевые треугольники
    var z = H / 2;
    var prevX = -A, prevY = fplus(prevX);
    for (var x = -A + step; Math.floor(x) < A; x += step) {
        var y = fminus(x);
        vertices.push(0, 0, z);
        vertices.push(prevX, prevY, z);
        vertices.push(x, y, z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        vertices.push(x, y, -z);
        vertices.push(x, y, z);
        vertices.push(prevX, prevY, z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        prevX = x;
        prevY = y;
    }
    var x = A, y = fminus(x);
    vertices.push(0, 0, z);
    vertices.push(prevX, prevY, z);
    vertices.push(x, y, z);

    geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

    vertices.push(x, y, -z);
    vertices.push(x, y, z);
    vertices.push(prevX, prevY, z);

    prevX = -A, prevY = fminus(prevX);
    for (var x = -A + step; x < A; x += step) {
        var y = fplus(x);
        vertices.push(x, y, z);
        vertices.push(prevX, prevY, z);
        vertices.push(0, 0, z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        vertices.push(prevX, prevY, -z);
        vertices.push(prevX, prevY, z);
        vertices.push(x, y, z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        prevX = x;
        prevY = y;
    }
    var x = A, y = fplus(x);
    vertices.push(x, y, z);
    vertices.push(prevX, prevY, z);
    vertices.push(0, 0, z);

    geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

    vertices.push(prevX, prevY, -z);
    vertices.push(prevX, prevY, z);
    vertices.push(x, y, z);

    geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

    // Задаем треуголники
    z = -H / 2;
    var prevX = -A, prevY = fplus(prevX);
    for (var x = -A + step; x < A; x += step) {
        var y = fplus(x);
        vertices.push(x, y, z);
        vertices.push(0, 0, z);
        vertices.push(prevX, prevY, z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        vertices.push(x, y, z);
        vertices.push(prevX, prevY, z);
        vertices.push(x, y, -z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        prevX = x;
        prevY = y;
    }
    var x = A, y = fplus(x);
    vertices.push(x, y, z);
    vertices.push(0, 0, z);
    vertices.push(prevX, prevY, z);

    geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

    vertices.push(x, y, z);
    vertices.push(prevX, prevY, z);
    vertices.push(x, y, -z);

    geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

    prevX = -A, prevY = fminus(prevX);
    for (var x = -A + step; x < A; x += step) {
        var y = fminus(x);

        vertices.push(prevX, prevY, z);
        vertices.push(0, 0, z);
        vertices.push(x, y, z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        vertices.push(prevX, prevY, -z);
        vertices.push(prevX, prevY, z);
        vertices.push(x, y, z);

        geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

        prevX = x;
        prevY = y;
    }
    var x = A, y = fminus(x);
    vertices.push(prevX, prevY, z);
    vertices.push(0, 0, z);
    vertices.push(x, y, z);

    geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

    vertices.push(prevX, prevY, -z);
    vertices.push(prevX, prevY, z);
    vertices.push(x, y, z);

    geometry.addAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));

    geometry.computeVertexNormals();
    return geometry;
}

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    render();
}

function render() {
    renderer.render(scene, camera);
}

function onLoad() {
    init();
    animate();
}