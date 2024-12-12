import ddf.minim.*;

int waveCount = 4;  // Total number of emotion categories
float[][] emotions = {
  {3, 4, 2, 6, 7, 5, 4, 6, 5, 8},   // Excitement
  {2, 3, 5, 8, 6, 3, 4, 7, 6, 4},   // Stress
  {8, 7, 6, 5, 4, 8, 9, 5, 7, 6},   // Calm
  {5, 6, 4, 7, 8, 6, 5, 8, 6, 7}    // Energy
};

// Graph settings
float margin = 60;
float graphWidth, graphHeight;
int numPoints = 10;  // Number of data points
float[][] currentPoints;
float animationSpeed = 0.05;  // Speed of the animation

// Particle glow effect
int particleCount = 50;
float[][] particlePositions;
float[] particleGlow;
float[] particleAngles;  // For wavy movement

// Rotating spirals
int spiralCount = 10;  // Number of spirals
float spiralRadius = 100;
float[][] spiralAngles;
float spiralSpeed = 0.01;

// Secret message properties
String secretMessage = "The deepest emotions are often unspoken, yet they echo endlessly within.";
boolean showSecretMessage = false;
float messageAlpha = 0;  // Transparency for fade-in effect
float messageX, messageY;  // Position of the message

// Audio variables
Minim minim;
AudioPlayer player;

void setup() {
  fullScreen(P2D);
  surface.setResizable(true);
  surface.setTitle("Emotion Visualizer");
  frameRate(60);

  // Initialize audio
  minim = new Minim(this);
  player = minim.loadFile("data/Music.mp3");  // Make sure your file is in the "data" folder
  if (player != null) {
    player.loop();  // Loop the music
    player.setGain(0);  // Set volume to normal
  } else {
    println("Error: Music file not loaded properly.");
  }

  graphWidth = width - 2 * margin;
  graphHeight = height - 2 * margin;
  currentPoints = new float[waveCount][numPoints];

  for (int i = 0; i < waveCount; i++) {
    for (int j = 0; j < numPoints; j++) {
      currentPoints[i][j] = height - margin;
    }
  }

  // Initialize particles for the glow effect
  particlePositions = new float[particleCount][2];
  particleGlow = new float[particleCount];
  particleAngles = new float[particleCount];

  for (int i = 0; i < particleCount; i++) {
    particlePositions[i][0] = random(margin, width - margin);
    particlePositions[i][1] = random(margin, height - margin);
    particleGlow[i] = random(50, 150);
    particleAngles[i] = random(TWO_PI);  // Randomize starting angle
  }

  // Initialize spirals
  spiralAngles = new float[spiralCount][2];
  for (int i = 0; i < spiralCount; i++) {
    spiralAngles[i][0] = random(TWO_PI);  // Random initial angle
    spiralAngles[i][1] = random(0.5, 1.5);  // Random speed
  }

  textSize(16);
  textAlign(CENTER, CENTER);
  strokeWeight(2);
}

void draw() {
  pulsingBackground();  // Pulsing background
  drawGradientBackground();  // Smooth gradient
  animateLines();  // Animated emotion lines
  drawLabels();    // Display emotion labels
  drawParticles(); // Animated particles
  drawSpirals();   // Rotating spirals

  if (showSecretMessage) {
    displaySecretMessage();
  } else {
    fadeOutMessage();
  }
}

void displaySecretMessage() {
  // Gradually increase the transparency of the message for a fade-in effect
  if (messageAlpha < 255) {
    messageAlpha += 2;
  }

  // Center the message on the screen
  float textWidth = textWidth(secretMessage); // Get the width of the text
  messageX = (width - textWidth) / 2;         // Position the text horizontally at the center
  messageY = height / 2;                      // Position the text vertically at the center

  fill(255, 255, 255, messageAlpha);  // White color with fading effect
  textSize(24);
  textAlign(CENTER, CENTER);   // Ensure the text is centered at the position
  text(secretMessage, messageX + textWidth / 2, messageY);  // Draw the text at the centered position
}

void fadeOutMessage() {
  // Gradually decrease the transparency of the message
  if (messageAlpha > 0) {
    messageAlpha -= 2;
  }
}

void keyPressed() {
  if (key == 'E' || key == 'e') {
    showSecretMessage = true;
  }
  if (key == 'S' || key == 's') {
    spiralSpeed += 0.01;  // Increase spiral speed
  }
  if (key == 'W' || key == 'w') {
    animationSpeed += 0.01;  // Increase wave animation speed
  }
}

void keyReleased() {
  if (key == 'E' || key == 'e') {
    showSecretMessage = false;
  }
}

void pulsingBackground() {
  float intensity = map(sin(frameCount * 0.01), -1, 1, 30, 60);  // Smooth pulse
  background(intensity, intensity, intensity + 10);  // Subtle color change
}

void drawGradientBackground() {
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(getEmotionColor(0), getEmotionColor(1), inter);  // Smooth transition from red to blue
    stroke(c);
    line(0, i, width, i);
  }
}

void animateLines() {
  noFill();
  for (int i = 0; i < waveCount; i++) {
    stroke(getWaveColor(i));
    beginShape();
    for (int j = 0; j < numPoints; j++) {
      float noiseOffset = random(-5, 5);  // Add randomness
      float targetY = map(emotions[i][j], 0, 10, height - margin, margin) + noiseOffset;
      currentPoints[i][j] = lerp(currentPoints[i][j], targetY, animationSpeed);
      float x = margin + j * (graphWidth / (numPoints - 1));
      float y = currentPoints[i][j];
      vertex(x, y);
    }
    endShape();
  }
}

void drawLabels() {
  textAlign(LEFT, CENTER);
  for (int i = 0; i < waveCount; i++) {
    float x = margin + (numPoints - 1) * (graphWidth / (numPoints - 1));
    float y = currentPoints[i][numPoints - 1];
    fill(getWaveColor(i));
    text(getWaveLabel(i), x + 10, y);
  }
}

void drawParticles() {
  noStroke();
  for (int i = 0; i < particleCount; i++) {
    float x = particlePositions[i][0];
    float y = particlePositions[i][1];
    float glow = particleGlow[i];

    // Apply wavy movement for a more ethereal effect
    float waveX = sin(particleAngles[i] + frameCount * 0.05) * 10;
    float waveY = cos(particleAngles[i] + frameCount * 0.05) * 10;
    particlePositions[i][0] += waveX;
    particlePositions[i][1] += waveY;

    fill(255, 255, 100, glow);  // Soft yellow glow to evoke warmth
    ellipse(x, y, 10, 10);  // Draw the particle

    particleGlow[i] = 100 + 50 * sin(frameCount * 0.05 + i);  // Pulsing glow effect

    // Keep particles within bounds
    if (particlePositions[i][0] < margin || particlePositions[i][0] > width - margin) {
      particlePositions[i][0] = random(margin, width - margin);
    }
    if (particlePositions[i][1] < margin || particlePositions[i][1] > height - margin) {
      particlePositions[i][1] = random(margin, height - margin);
    }
  }
}

void drawSpirals() {
  translate(width / 2, height / 2);  // Center of the screen
  for (int i = 0; i < spiralCount; i++) {
    float angle = spiralAngles[i][0];
    float speed = spiralAngles[i][1];
    float x = cos(angle) * spiralRadius * (1 + 0.5 * sin(frameCount * 0.02));
    float y = sin(angle) * spiralRadius * (1 + 0.5 * sin(frameCount * 0.02));

    fill(255, 200, 150, 150);  // Light orange
    noStroke();
    ellipse(x, y, 15, 15);  // Glow effect

    spiralAngles[i][0] += speed * spiralSpeed;  // Rotate
  }
  resetMatrix();  // Reset transformation
}

color getWaveColor(int index) {
  switch (index) {
    case 0: return color(255, 100, 100);  // Red for Excitement
    case 1: return color(255, 200, 100);  // Yellow for Stress
    case 2: return color(100, 200, 255);  // Blue for Calm
    case 3: return color(150, 255, 150);  // Green for Energy
    default: return color(255);
  }
}

String getWaveLabel(int index) {
  switch (index) {
    case 0: return "Joy";
    case 1: return "Stress";
    case 2: return "Calm";
    case 3: return "Energy";
    default: return "Unknown";
  }
}

color getEmotionColor(int index) {
  switch (index) {
    case 0: return color(255, 100, 100);  // Red
    case 1: return color(100, 200, 255);  // Blue
    default: return color(200, 200, 200); // Default light gray
  }
}

//Citations
//Behance, n.d. Processing Music Visualization. Available at: https://www.behance.net/gallery/Processing-Music-Visualization/15659061 [Accessed 08 December 2024].
//Processing Forum, n.d. Creating a Music Visualizer with a Tone Matrix. Available at: https://forum.processing.org/two/discussions [Accessed 10 December 2024].
