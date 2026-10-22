param(
    [ValidateSet('Check','Run')][string]$Mode = 'Check',
    [string]$Namespace = 'lab-lifecycle-smoke',
    [switch]$Keep
)
$ErrorActionPreference = 'Stop'
if ($Namespace -notmatch '^lab-[a-z0-9-]+$') { throw 'Namespace must begin with lab- to reduce deletion risk.' }
function Invoke-Kubectl([string[]]$Arguments) {
    & kubectl @Arguments
    if ($LASTEXITCODE -ne 0) { throw "kubectl $($Arguments -join ' ') failed ($LASTEXITCODE)" }
}
$context = (& kubectl config current-context).Trim()
if ($LASTEXITCODE -ne 0 -or $context -ne 'minikube') { throw "Refusing to run: expected context minikube, got '$context'." }
Invoke-Kubectl @('cluster-info')
Invoke-Kubectl @('get','nodes')
if ($Mode -eq 'Check') { Write-Host '[PASS] minikube context and API available'; exit 0 }
$exists = & kubectl get namespace $Namespace --ignore-not-found -o name
if ($LASTEXITCODE -ne 0) { throw 'Could not check namespace.' }
if ($exists) { throw "Namespace $Namespace already exists; refusing to modify/delete user resources. Choose a new lab- namespace." }
$created = $false
try {
    Invoke-Kubectl @('create','namespace',$Namespace)
    $created = $true
    foreach ($round in 1..2) {
        Write-Host "[Round $round] Create"
        Invoke-Kubectl @('create','deployment','web','--image=nginx:1.27-alpine','-n',$Namespace)
        Invoke-Kubectl @('rollout','status','deployment/web','-n',$Namespace,'--timeout=180s')
        Invoke-Kubectl @('scale','deployment/web','--replicas=2','-n',$Namespace)
        Invoke-Kubectl @('rollout','status','deployment/web','-n',$Namespace,'--timeout=180s')
        $replicas = (& kubectl get deployment web -n $Namespace -o 'jsonpath={.status.readyReplicas}').Trim()
        if ($LASTEXITCODE -ne 0 -or $replicas -ne '2') { throw "Expected 2 ready replicas; actual '$replicas'" }
        Write-Host "[Round $round] Update and rollback"
        Invoke-Kubectl @('set','image','deployment/web','nginx=nginx:1.28-alpine','-n',$Namespace)
        Invoke-Kubectl @('rollout','status','deployment/web','-n',$Namespace,'--timeout=180s')
        Invoke-Kubectl @('rollout','undo','deployment/web','-n',$Namespace)
        Invoke-Kubectl @('rollout','status','deployment/web','-n',$Namespace,'--timeout=180s')
        Write-Host "[Round $round] Delete and verify"
        Invoke-Kubectl @('delete','deployment/web','-n',$Namespace,'--wait=true','--timeout=120s')
        $left = & kubectl get deployment web -n $Namespace --ignore-not-found -o name
        if ($LASTEXITCODE -ne 0 -or $left) { throw "Deployment was not removed: $left" }
        $pods = & kubectl get pods -n $Namespace -l app=web --no-headers --ignore-not-found 2>$null
        if ($LASTEXITCODE -ne 0 -or $pods) { throw 'Experiment Pods remain after Deployment deletion.' }
        Write-Host "[PASS] round $round"
    }
}
finally {
    if ($created -and -not $Keep) {
        Invoke-Kubectl @('delete','namespace',$Namespace,'--wait=true','--timeout=180s')
    }
}
Write-Host '[PASS] two deployment lifecycle rounds completed'
