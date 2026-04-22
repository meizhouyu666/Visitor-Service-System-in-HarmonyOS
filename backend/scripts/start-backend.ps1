$dbHost = '127.0.0.1'
$dbPort = 3306

$connection = Test-NetConnection -ComputerName $dbHost -Port $dbPort -WarningAction SilentlyContinue
if (-not $connection.TcpTestSucceeded) {
  Write-Host "[ERROR] MySQL 未就绪：$dbHost:$dbPort 无法连接。" -ForegroundColor Red
  Write-Host "请先在 backend 目录执行：docker compose up -d" -ForegroundColor Yellow
  exit 1
}

Write-Host "[OK] MySQL 已就绪，启动后端服务..." -ForegroundColor Green
mvn spring-boot:run
