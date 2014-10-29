#version 120

attribute vec4 a_position;
attribute vec3 a_color;

varying vec3 v_color;

void main() {
    gl_Position = a_position;
    v_color = a_color;
}
