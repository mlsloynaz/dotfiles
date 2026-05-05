@echo off
cd /d "C:\Users\malu.loynaz\OneDrive - ByDesign Technologies\Documents\Projects\00-InventoryPrices"
npx --yes http-server . -p 9000 -a 0.0.0.0 %*
