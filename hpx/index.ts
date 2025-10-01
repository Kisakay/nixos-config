import hid, { HID } from "node-hid";

// Find supported HID device
function findSupportedDevice() {
    const devices = hid.devices();

    for (const device of devices) {
        const vendorId = device.vendorId;
        const productId = device.productId;
        const manufacturer = device.manufacturer || '';
        const product = device.product || '';

        // Check for HP, HyperX, or Kingston manufacturers
        if (manufacturer && (manufacturer.includes("HP") || manufacturer.includes("HyperX") || manufacturer.includes("Kingston"))) {
            const supportedProducts = [
                "Cloud II Core",
                "Cloud II Wireless",
                "Cloud Stinger 2 Wireless",
                "Cloud Alpha Wireless"
            ];

            if (supportedProducts.some(keyword => product.includes(keyword))) {
                return { vendorId, productId, manufacturer, product };
            }
        }
    }

    return { vendorId: null, productId: null, manufacturer: null, product: null };
}

// Get battery level from device
async function getBatteryLevel() {
    const { vendorId, productId, manufacturer, product } = findSupportedDevice();

    if (!vendorId) {
        return { battery: null, productId: null, product: null };
    }

    let device;
    try {
        device = new HID(vendorId, productId);
    } catch (error) {
        console.error("Failed to open device:", error);
        return { battery: null, productId, product };
    }

    // Initialize write buffer
    const writeBuffer = new Array(52).fill(0x00);
    let batteryByteIndex = 7;

    // Configure command based on manufacturer and product
    if (manufacturer.includes("HP")) {
        if (product.includes("Cloud II Core")) {
            writeBuffer[0] = 0x66;
            writeBuffer[1] = 0x89;
            batteryByteIndex = 4;
        } else if (product.includes("Cloud II Wireless") || product.includes("Cloud Stinger 2 Wireless")) {
            writeBuffer[0] = 0x06;
            writeBuffer[1] = 0xff;
            writeBuffer[2] = 0xbb;
            writeBuffer[3] = 0x02;
        } else if (product.includes("Cloud Alpha Wireless")) {
            writeBuffer[0] = 0x21;
            writeBuffer[1] = 0xbb;
            writeBuffer[2] = 0x0b;
            batteryByteIndex = 3;
        }
    } else {
        // Kingston / HyperX variant
        try {
            // Try to get input report first
            device.getFeatureReport(6, 160);
        } catch (error) {
            device.close();
            return { battery: null, productId, product };
        }

        writeBuffer[0] = 0x06;
        writeBuffer[2] = 0x02;
        writeBuffer[4] = 0x9a;
        writeBuffer[7] = 0x68;
        writeBuffer[8] = 0x4a;
        writeBuffer[9] = 0x8e;
        writeBuffer[10] = 0x0a;
        writeBuffer[14] = 0xbb;
        writeBuffer[15] = 0x02;
    }

    try {
        // Write command to device
        device.write(Buffer.from(writeBuffer));

        // Set timeout for reading response
        const timeout = 1000; // 1 second
        const startTime = Date.now();

        // Attempt to read response
        let response: number[] | null = null;
        while (Date.now() - startTime < timeout) {
            try {
                response = device.readTimeout(10) as number[]; // 10ms timeout per read
                if (response && response.length > 0) {
                    break;
                }
            } catch (error) {
                // Continue trying until main timeout
            }

            // Small delay to avoid busy waiting
            await new Promise(resolve => setTimeout(resolve, 10));
        }

        device.close();

        if (response && response.length > batteryByteIndex) {
            return { battery: response[batteryByteIndex], productId, product };
        } else {
            return { battery: null, productId, product };
        }

    } catch (error) {
        process.stdout.write((error as Error).message + "\n");
        device.close();
        return { battery: null, productId, product };
    }
}

// Main execution
async function main() {
    const { battery, productId, product } = await getBatteryLevel();

    if (productId && battery !== null) {
        process.stdout.write(`🎧 ${battery}%\n`)
    } else if (productId) {
        process.stdout.write(`🎧 ${product} - ?%\n`)
    } else {
        process.stdout.write(`?\n`);
    }
    process.exit(0);
}
// Run the script
main().catch(() => process.exit(1));
