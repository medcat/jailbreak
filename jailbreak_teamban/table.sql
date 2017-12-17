CREATE TABLE IF NOT EXISTS sm_jailbreak_teambans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  auth VARCHAR(32) NOT NULL,
  admin VARCHAR(32) NOT NULL,
  start INT NOT NULL,
  length INT NOT NULL,
  current INT NOT NULL,
  active INT NOT NULL DEFAULT 1
);

CREATE INDEX length_index ON sm_jailbreak_teambans (length);
CREATE INDEX auth_index ON sm_jailbreak_teambans (auth);
CREATE INDEX current_index ON sm_jailbreak_teambans (current);
CREATE INDEX length_current_index ON sm_jailbreak_teambans (length, current);
