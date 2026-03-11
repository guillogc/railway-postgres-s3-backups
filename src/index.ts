import { backup } from "./backup.js";

console.log("Running backup...");

try {
    await backup();
    console.log("Database backup complete.");
} catch (error) {
    console.error("Error while running backup: ", error);
    process.exit(1);
}
