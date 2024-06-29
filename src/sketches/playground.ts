import type P5 from "p5";

import frag from "./shader.frag.glsl?raw";
import vert from "./shader.vert.glsl?raw";

export const sketch = (p: P5) => {
  let renderer: P5.Renderer | undefined;
  let shader: P5.Shader;

  p.setup = () => {
    p.width = 640;
    p.height = 480;
    renderer = p.createCanvas(p.width, p.height, p.WEBGL);
    shader = p.createShader(vert, frag);
    shader.setUniform("uRes", [p.width, p.height]);
    p.shader(shader);
    p.noStroke();

    renderer.mouseMoved((e: MouseEvent) => {
      const rect = (e.currentTarget as Element).getBoundingClientRect();
      requestAnimationFrame(() => {
        const mouse = [
          Math.max(-1, Math.min(1, (e.clientX - rect.left) / p.width) * 2 - 1),
          Math.max(-1, Math.min(1, (e.clientY - rect.top) / p.height) * 2 - 1),
        ];
        shader.setUniform("uMouse", mouse);
      });
    });
  };

  p.draw = () => {
    shader.setUniform("uTime", p.millis() / 1000);

    p.quad(-1, -1, -1, 1, 1, 1, 1, -1);
  };
};
