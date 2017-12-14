CREATE TABLE IF NOT EXISTS sm_jailbreak_teambans (
  PRIMARY KEY id,
  auth VARCHAR(64) NOT NULL,
  start INT NOT NULL,
  length INT NOT NULL,
  current INT NOT NULL
);

CREATE INDEX length_index ON sm_jailbreak_teambans (length);
CREATE INDEX current_index ON sm_jailbreak_teambans (current);
CREATE INDEX length_current_index ON sm_jailbreak_teambans (length, current);
