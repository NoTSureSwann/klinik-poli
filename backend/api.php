<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$host = "127.0.0.1";
$db_name = "klinik_db";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=" . $host . ";dbname=" . $db_name, $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $exception) {
    echo json_encode(["status" => false, "message" => "Connection error: " . $exception->getMessage()]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
// Get entity from URL parameter e.g., ?entity=pasien
$entity = isset($_GET['entity']) ? $_GET['entity'] : '';

// Get Action for specific calls like login, etc.
$action = isset($_GET['action']) ? $_GET['action'] : '';

// Function to generate UUID
function gen_uuid() {
    return sprintf( '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ),
        mt_rand( 0, 0xffff ),
        mt_rand( 0, 0x0fff ) | 0x4000,
        mt_rand( 0, 0x3fff ) | 0x8000,
        mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff ), mt_rand( 0, 0xffff )
    );
}

// ------------------------------------------------------------------
// REKAM MEDIS & RESEP LOGIC
// ------------------------------------------------------------------
if ($action == 'simpan_rekam_medis') {
    $data = json_decode(file_get_contents("php://input"), true);
    
    try {
        $conn->beginTransaction();
        
        $rekam_medis_id = gen_uuid();
        $stmtRM = $conn->prepare("INSERT INTO rekam_medis (id, antrian_id, pasien_id, pegawai_id, diagnosa, biaya_jasa, total_biaya_obat, status_pembayaran) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmtRM->execute([
            $rekam_medis_id,
            $data['antrian_id'],
            $data['pasien_id'],
            $data['pegawai_id'],
            $data['diagnosa'],
            $data['biaya_jasa'],
            $data['total_biaya_obat'],
            $data['status_pembayaran'] ?? 'Belum Lunas'
        ]);

        if (isset($data['resep']) && is_array($data['resep'])) {
            $stmtResep = $conn->prepare("INSERT INTO resep_obat (id, rekam_medis_id, obat_id, jumlah, harga_satuan, subtotal) VALUES (?, ?, ?, ?, ?, ?)");
            $stmtUpdateStok = $conn->prepare("UPDATE obat SET stok = stok - ? WHERE id = ?");
            
            foreach ($data['resep'] as $item) {
                $resep_id = gen_uuid();
                $stmtResep->execute([
                    $resep_id,
                    $rekam_medis_id,
                    $item['obat_id'],
                    $item['jumlah'],
                    $item['harga_satuan'],
                    $item['subtotal']
                ]);
                $stmtUpdateStok->execute([$item['jumlah'], $item['obat_id']]);
            }
        }
        
        $conn->commit();
        echo json_encode(["status" => true, "id" => $rekam_medis_id, "message" => "Rekam Medis & Resep berhasil disimpan"]);
    } catch (Exception $e) {
        $conn->rollBack();
        echo json_encode(["status" => false, "message" => "Gagal menyimpan rekam medis: " . $e->getMessage()]);
    }
    exit();
}

// ------------------------------------------------------------------
// LOGIN LOGIC
// ------------------------------------------------------------------
if ($action == 'login') {
    $data = json_decode(file_get_contents("php://input"));
    $user = $data->username ?? '';
    $pass = $data->password ?? '';

    // Admin hardcoded logic (optional, best moved to DB)
    if ($user == 'admin' && $pass == 'admin') {
        echo json_encode(["status" => true, "role" => "Admin", "id" => "admin_id", "nama" => "Administrator"]);
        exit();
    }

    // Check Pegawai
    $stmt = $conn->prepare("SELECT id, nama_pegawai, jabatan_pegawai FROM pegawai WHERE email_pegawai=? AND password_pegawai=?");
    $stmt->execute([$user, $pass]);
    if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo json_encode(["status" => true, "role" => $row['jabatan_pegawai'], "id" => $row['id'], "nama" => $row['nama_pegawai']]);
        exit();
    }

    // Check Pasien
    $stmt = $conn->prepare("SELECT id, nama_pasien FROM pasien WHERE username=? AND password=?");
    $stmt->execute([$user, $pass]);
    if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo json_encode(["status" => true, "role" => "Pasien", "id" => $row['id'], "nama" => $row['nama_pasien']]);
        exit();
    }

    echo json_encode(["status" => false, "message" => "Invalid credentials"]);
    exit();
}

// ------------------------------------------------------------------
// QUEUE / ANTRIAN LOGIC
// ------------------------------------------------------------------
if ($action == 'next_counter') {
    $poliId = $_GET['poli_id'];
    $tanggal = $_GET['tanggal'];
    $id = $poliId . "_" . $tanggal;

    $stmt = $conn->prepare("SELECT current FROM counters WHERE id = ?");
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        $next = $row['current'] + 1;
        $stmt = $conn->prepare("UPDATE counters SET current = ? WHERE id = ?");
        $stmt->execute([$next, $id]);
    } else {
        $next = 1;
        $stmt = $conn->prepare("INSERT INTO counters (id, poli_id, tanggal, current) VALUES (?, ?, ?, ?)");
        $stmt->execute([$id, $poliId, $tanggal, $next]);
    }
    
    echo json_encode(["status" => true, "counter" => $next]);
    exit();
}

// ------------------------------------------------------------------
// CRUD LOGIC
// ------------------------------------------------------------------
if (!$entity) {
    echo json_encode(["status" => false, "message" => "Entity not specified"]);
    exit();
}

switch($method) {
    case 'GET':
        // Optional Search Param
        $search = isset($_GET['search']) ? $_GET['search'] : '';
        $id = isset($_GET['id']) ? $_GET['id'] : '';
        $whereClause = "";
        $params = [];

        // Simple filtering (Optimization using LIKE)
        if ($id) {
            $whereClause = "WHERE id = ?";
            $params[] = $id;
        } else if ($search) {
            // Find column for searching dynamically based on entity
            $colName = 'nama_' . $entity; 
            // e.g., nama_pasien, nama_pegawai
            if ($entity == 'antrian') {
                $colName = 'nomor_antrian';
            }
            $whereClause = "WHERE $colName LIKE ?";
            $params[] = "%$search%";
        }

        // Additional filters for Antrian
        if ($entity == 'antrian' && isset($_GET['poli_id'])) {
            $whereClause = $whereClause ? $whereClause . " AND poli_id = ?" : "WHERE poli_id = ?";
            $params[] = $_GET['poli_id'];
        }
        if ($entity == 'antrian' && isset($_GET['tanggal'])) {
            $whereClause = $whereClause ? $whereClause . " AND tanggal = ?" : "WHERE tanggal = ?";
            $params[] = $_GET['tanggal'];
        }

        $stmt = $conn->prepare("SELECT * FROM $entity $whereClause");
        $stmt->execute($params);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(["status" => true, "data" => $result]);
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        if (!$data) $data = $_POST;
        
        $id = isset($data['id']) && $data['id'] ? $data['id'] : gen_uuid();
        $data['id'] = $id;

        $columns = implode(", ", array_keys($data));
        $placeholders = implode(", ", array_fill(0, count($data), "?"));
        
        $stmt = $conn->prepare("INSERT INTO $entity ($columns) VALUES ($placeholders)");
        try {
            $stmt->execute(array_values($data));
            echo json_encode(["status" => true, "id" => $id, "message" => "Created successfully"]);
        } catch(PDOException $e) {
            echo json_encode(["status" => false, "message" => $e->getMessage()]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);
        if(!isset($data['id'])) {
            echo json_encode(["status" => false, "message" => "ID is required"]);
            exit();
        }
        $id = $data['id'];
        unset($data['id']);

        $setClause = "";
        $params = [];
        foreach($data as $key => $value) {
            $setClause .= "$key = ?, ";
            $params[] = $value;
        }
        $setClause = rtrim($setClause, ", ");
        $params[] = $id;

        $stmt = $conn->prepare("UPDATE $entity SET $setClause WHERE id = ?");
        try {
            $stmt->execute($params);
            echo json_encode(["status" => true, "message" => "Updated successfully"]);
        } catch(PDOException $e) {
            echo json_encode(["status" => false, "message" => $e->getMessage()]);
        }
        break;

    case 'DELETE':
        $data = json_decode(file_get_contents("php://input"), true);
        $id = $data['id'] ?? (isset($_GET['id']) ? $_GET['id'] : null);
        
        if(!$id) {
            echo json_encode(["status" => false, "message" => "ID is required"]);
            exit();
        }

        $stmt = $conn->prepare("DELETE FROM $entity WHERE id = ?");
        try {
            $stmt->execute([$id]);
            echo json_encode(["status" => true, "message" => "Deleted successfully"]);
        } catch(PDOException $e) {
            echo json_encode(["status" => false, "message" => $e->getMessage()]);
        }
        break;
}
?>
