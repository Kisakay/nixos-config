import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import * as readline from "node:readline";
import * as process from "node:process";
import * as crypto from "node:crypto";
import * as child from "node:child_process";

// ANSI color codes for terminal output
const Color = { Black: "\x1b[30m", Red: "\x1b[31m", Green: "\x1b[32m", Yellow: "\x1b[33m", Blue: "\x1b[34m", Magenta: "\x1b[35m", Cyan: "\x1b[36m", White: "\x1b[37m", BGBlack: "\x1b[40m", BGRed: "\x1b[41m", BGGreen: "\x1b[42m", BGYellow: "\x1b[43m", BGBlue: "\x1b[44m", BGMagenta: "\x1b[45m", BGCyan: "\x1b[46m", BGWhite: "\x1b[47m", Dim: "\x1b[2m", Italic: "\x1b[3m", Underscore: "\x1b[4m", Reverse: "\x1b[7m", Hidden: "\x1b[8m", Strikethrough: "\x1b[9m", Gray: "\x1b[90m", Bold: "\x1b[1m", Reset: "\x1b[0m" };
const EndLine = '\n';

const PATH = path.join(
    process.env.HOME || os.homedir(),
    '.var',
    'app',
    'com.opera.Opera',
    'config'
);

const DEFAULT_CURRENT_PROFILE = "opera";

const DEFAULT_CURRENT_PROFILE_PATH = path.join(PATH, DEFAULT_CURRENT_PROFILE);
let profiles: {
    name: string;
    path: string;
}[] = [];

detectProfileFolder()

process.stdout.write(Color.Blue + "Opera Profile Switcher " + Color.Reset);
process.stdout.write(Color.Dim + "by github.com/Kisakay" + Color.Reset + EndLine + EndLine);
process.stdout.write(Color.Green + "Current profile: " + Color.Reset + currentProfileIs().split('_')[1] + EndLine);
process.stdout.write(Color.Green + "Current profile ID: " + Color.Reset + currentProfileIs().split('_')[0] + EndLine);

process.stdout.write(Color.Yellow + "Available profiles: " + Color.Reset + profiles.map(x => x.name.split('_')[1]).join(', ') + EndLine + EndLine);



// we admit current profile is the PATH + "/opera"

function currentProfileIs(): string {
    // read the current profile from the config file
    const configFilePath = path.join(DEFAULT_CURRENT_PROFILE_PATH, '.kisakay_profile_switcher');
    if (fs.existsSync(configFilePath)) {
        const currentProfile = fs.readFileSync(configFilePath, 'utf-8').trim();
        return currentProfile;
    } else {
        return DEFAULT_CURRENT_PROFILE;
    }
}

function generateProfileIdentifier(): string {
    // using crypto random bytes to generate a unique identifier
    return crypto.randomBytes(8).toString('hex');
}

function generateProfileConfig(path: string, name: string): string {
    const profileId = generateProfileIdentifier().toUpperCase();
    fs.writeFileSync(path, `${profileId}_${name}`, 'utf-8');
    return `${profileId}_${name}`;
}

function detectProfileFolder() {
    const folders = fs.readdirSync(PATH).filter(file => fs.statSync(path.join(PATH, file)).isDirectory());

    if (folders.length === 0) {
        process.stdout.write(Color.Red + "No profiles found in " + PATH + Color.Reset + EndLine);
        process.exit(1);
    }

    // Check if in the folders we have the default profile and browser.js
    for (const folder of folders) {
        const folderPath = path.join(PATH, folder);

        if (fs.existsSync(path.join(folderPath, 'browser.js')) && fs.existsSync(path.join(folderPath, 'Default'))) {
            // Check if we have .kisakay_profile_switcher file
            if (fs.existsSync(path.join(folderPath, '.kisakay_profile_switcher'))) {
                process.stdout.write(Color.Green + "Found " + Color.White + ".kisakay_profile_switcher " + Color.Green + "in profile: " + Color.White + folder + Color.Reset + EndLine);
                const profileId = fs.readFileSync(path.join(folderPath, '.kisakay_profile_switcher'), 'utf-8').trim();
                profiles.push({
                    name: profileId,
                    path: folderPath
                });
            } else {
                // create a new .kisakay_profile_switcher file with a unique identifier
                const profileId = generateProfileConfig(path.join(folderPath, '.kisakay_profile_switcher'), folder);
                process.stdout.write(Color.Yellow + "Created new .kisakay_profile_switcher with ID: " + profileId + " in profile: " + Color.Reset + Color.White + folder + Color.Reset + EndLine);
                profiles.push({
                    name: profileId,
                    path: folderPath
                });
            }
        }
    }
    return folders;
}

function ask(question: string): Promise<{ x: string }> {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    return new Promise<{ x: string }>((resolve) => {
        rl.question(question, (answer) => {
            rl.close();
            resolve({ x: answer.trim() });
        });
    });
}

ask(Color.Cyan + "Enter the profile name to switch to: " + Color.Reset).then(({ x }) => switchProfile(x));

// this function will switch move the default 'opera' folder to new one like 'opera_old' and move the selected profile to 'opera'
function switchProfile(profileName: string): Promise<void> {
    const selectedProfile = profiles.find(p => p.name.endsWith(`_${profileName}`));
    if (!selectedProfile) {
        process.stdout.write(Color.Red + "Profile not found: " + profileName + Color.Reset + EndLine);
        process.exit(1);
    }

    // Move current 'opera' to 'opera_old'
    const backupPath = path.join(PATH, 'opera_old_' + Date.now());
    if (fs.existsSync(DEFAULT_CURRENT_PROFILE_PATH)) {
        if (fs.existsSync(backupPath)) {
            fs.rmSync(backupPath, { recursive: true, force: true });
        }
        fs.renameSync(DEFAULT_CURRENT_PROFILE_PATH, backupPath);
        process.stdout.write(Color.Yellow + "Backed up current profile to: " + backupPath + Color.Reset + EndLine);
    }

    // Move selected profile to 'opera'
    fs.renameSync(selectedProfile.path, DEFAULT_CURRENT_PROFILE_PATH);
    process.stdout.write(Color.Green + "Switched to profile: " + profileName + Color.Reset + EndLine);
    runOpera();

    process.exit(0);
}

function runOpera(): void {
    // run atomicly opera
    child.exec('flatpak run com.opera.Opera & disown', (error: any, stdout: string, stderr: string) => {
        if (error) {
            process.stdout.write(Color.Red + `Error launching Opera: ${error.message}` + Color.Reset + EndLine);
            return;
        }
        if (stderr) {
            process.stdout.write(Color.Red + `Opera stderr: ${stderr}` + Color.Reset + EndLine);
            return;
        }
        process.stdout.write(Color.Green + `Opera launched successfully.` + Color.Reset + EndLine);
    });
}