import { backup } from "./backup.js";
import { sendDiscordNotification } from "./discord.js";

console.log("Running backup...");

try {
    const { filename, size } = await backup();
    console.log("Database backup complete.");
    await sendDiscordNotification("", { backup: { filename, size } });
} catch (error) {
    console.error("Error while running backup: ", error);
    let message: string;
    if (error instanceof Error) {
        message = error.message;
    } else if (typeof error === "object" && error !== null) {
        const obj = error as { stderr?: string; error?: Error };
        message =
            obj.stderr ?? (obj.error instanceof Error ? obj.error.message : JSON.stringify(error));
    } else {
        message = String(error);
    }
    await sendDiscordNotification(`❌ Backup failed: ${message}`, { isError: true });
    process.exit(1);
}
