import { ethers } from "hardhat";
import { join } from "path";
import * as fs from "fs";
import * as QRCode from "qrcode";

async function main() {
  const COUNT = 50;
  const QRCODE_FOLDER = "./qrcodes";
  const disperseAmount = 5;
  const wallet = ethers.Wallet.createRandom({ entropy: ethers.utils.randomBytes(32) });
  const words = wallet.mnemonic.phrase;
  const node = ethers.utils.HDNode.fromMnemonic(words);

  console.log("MNEMONIC: %s", words);
  fs.mkdir(join(__dirname, QRCODE_FOLDER), { recursive: true }, (err) => {
    if (err) throw err;
  });

  let accounts = "";
  let disperse = "";

  for (let i = 0; i < COUNT; i++) {
    const account = node.derivePath(`m/44'/60'/0'/0/${i}`);
    accounts += `${account.index},${account.address},${account.privateKey}\n`;
    disperse += `${account.address},${disperseAmount}\n`;
    await QRCode.toFile(
      join(__dirname, `${QRCODE_FOLDER}/qr-${account.index}-${account.address}.png`),
      account.privateKey
    );
  }

  fs.writeFileSync(join(__dirname, "./mnemonic.csv"), words, { flag: "w" });
  fs.writeFileSync(join(__dirname, "./wallets.csv"), accounts, { flag: "w" });
  fs.writeFileSync(join(__dirname, "./disperse.csv"), disperse, { flag: "w" });
  console.log(accounts);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
