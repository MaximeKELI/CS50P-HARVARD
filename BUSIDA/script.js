document.addEventListener('DOMContentLoaded', function() {
    // Données des villes du Togo avec coordonnées approximatives et distances
    const villesTogo = {
        'Lomé': { lat: 6.130419, lng: 1.215829, distances: {
            'Kara': 413, 'Sokodé': 355, 'Atakpamé': 161, 'Dapaong': 638, 
            'Tsévié': 35, 'Aného': 45, 'Kpalimé': 121, 'Bassar': 425, 'Mango': 711
        }},
        'Kara': { lat: 9.551111, lng: 1.186111, distances: {
            'Lomé': 413, 'Sokodé': 112, 'Atakpamé': 280, 'Dapaong': 225, 
            'Tsévié': 448, 'Aného': 458, 'Kpalimé': 534, 'Bassar': 12, 'Mango': 298
        }},
        'Sokodé': { lat: 8.983333, lng: 1.133333, distances: {
            'Lomé': 355, 'Kara': 112, 'Atakpamé': 168, 'Dapaong': 337, 
            'Tsévié': 390, 'Aného': 400, 'Kpalimé': 476, 'Bassar': 124, 'Mango': 410
        }},
        'Atakpamé': { lat: 7.533333, lng: 1.133333, distances: {
            'Lomé': 161, 'Kara': 280, 'Sokodé': 168, 'Dapaong': 505, 
            'Tsévié': 196, 'Aného': 206, 'Kpalimé': 282, 'Bassar': 292, 'Mango': 578
        }},
        'Dapaong': { lat: 10.866667, lng: 0.2, distances: {
            'Lomé': 638, 'Kara': 225, 'Sokodé': 337, 'Atakpamé': 505, 
            'Tsévié': 673, 'Aného': 683, 'Kpalimé': 759, 'Bassar': 237, 'Mango': 73
        }},
        'Tsévié': { lat: 6.433333, lng: 1.216667, distances: {
            'Lomé': 35, 'Kara': 448, 'Sokodé': 390, 'Atakpamé': 196, 
            'Dapaong': 673, 'Aného': 80, 'Kpalimé': 86, 'Bassar': 460, 'Mango': 746
        }},
        'Aného': { lat: 6.233333, lng: 1.6, distances: {
            'Lomé': 45, 'Kara': 458, 'Sokodé': 400, 'Atakpamé': 206, 
            'Dapaong': 683, 'Tsévié': 80, 'Kpalimé': 166, 'Bassar': 470, 'Mango': 756
        }},
        'Kpalimé': { lat: 6.9, lng: 0.633333, distances: {
            'Lomé': 121, 'Kara': 534, 'Sokodé': 476, 'Atakpamé': 282, 
            'Dapaong': 759, 'Tsévié': 86, 'Aného': 166, 'Bassar': 546, 'Mango': 832
        }},
        'Bassar': { lat: 9.25, lng: 0.783333, distances: {
            'Lomé': 425, 'Kara': 12, 'Sokodé': 124, 'Atakpamé': 292, 
            'Dapaong': 237, 'Tsévié': 460, 'Aného': 470, 'Kpalimé': 546, 'Mango': 310
        }},
        'Mango': { lat: 10.366667, lng: 0.466667, distances: {
            'Lomé': 711, 'Kara': 298, 'Sokodé': 410, 'Atakpamé': 578, 
            'Dapaong': 73, 'Tsévié': 746, 'Aného': 756, 'Kpalimé': 832, 'Bassar': 310
        }}
    };

    // Tarifs par classe (FCFA par km)
    const tarifs = {
        'Economique': 50,
        'Confort': 75,
        'VIP': 120
    };

    // Initialiser le localStorage si vide
    if (!localStorage.getItem('tickets')) {
        localStorage.setItem('tickets', JSON.stringify([]));
    }
    
    if (!localStorage.getItem('users')) {
        localStorage.setItem('users', JSON.stringify([]));
    }
    
    // Charger les tickets existants
    loadTickets();
    
    // Navigation entre sections
    document.querySelectorAll('nav ul li a').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Retirer la classe active de tous les liens
            document.querySelectorAll('nav ul li a').forEach(l => l.classList.remove('active'));
            
            // Ajouter la classe active au lien cliqué
            this.classList.add('active');
            
            // Masquer toutes les sections
            document.querySelectorAll('.content-section').forEach(section => {
                section.style.display = 'none';
            });
            
            // Afficher la section correspondante
            const sectionId = this.id.replace('nav', '') + 'Section';
            const section = document.getElementById(sectionId);
            section.style.display = 'block';
            section.classList.add('animate__fadeIn');
            
            // Charger le contenu spécifique si nécessaire
            if (sectionId === 'horairesSection') loadHoraires();
            if (sectionId === 'tarifsSection') loadTarifs();
            if (sectionId === 'contactSection') loadContact();
        });
    });
    
    // Gérer la soumission du formulaire de réservation
    const reservationForm = document.getElementById('reservationForm');
    reservationForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Récupérer les valeurs du formulaire
        const nom = document.getElementById('nom').value;
        const depart = document.getElementById('depart').value;
        const arrivee = document.getElementById('arrivee').value;
        const date = document.getElementById('date').value;
        const heure = document.getElementById('heure').value;
        const places = document.getElementById('places').value;
        const classe = document.getElementById('classe').value;
        
        // Vérifier que départ et arrivée sont différents
        if (depart === arrivee) {
            showAlert('error', 'La ville de départ et d\'arrivée doivent être différentes');
            return;
        }
        
        // Calculer le prix
        const distance = villesTogo[depart].distances[arrivee];
        const prixUnitaire = distance * tarifs[classe];
        const prixTotal = prixUnitaire * places;
        
        // Créer un nouveau ticket
        const newTicket = {
            id: Date.now(),
            nom,
            depart,
            arrivee,
            date,
            heure,
            places,
            classe,
            distance,
            prixUnitaire,
            prixTotal,
            dateReservation: new Date().toLocaleString('fr-FR'),
            statut: 'confirmé'
        };
        
        // Ajouter le ticket au localStorage
        const tickets = JSON.parse(localStorage.getItem('tickets'));
        tickets.push(newTicket);
        localStorage.setItem('tickets', JSON.stringify(tickets));
        
        // Recharger la liste des tickets
        loadTickets();
        
        // Réinitialiser le formulaire
        reservationForm.reset();
        
        // Afficher un message de confirmation
        showAlert('success', `Réservation confirmée pour ${nom} (${depart} → ${arrivee})`);
        
        // Afficher le ticket dans un modal
        showTicketModal(newTicket);
    });
    
    // Gérer le changement de ville de départ ou d'arrivée
    document.getElementById('depart').addEventListener('change', updateRouteInfo);
    document.getElementById('arrivee').addEventListener('change', updateRouteInfo);
    
    function updateRouteInfo() {
        const depart = document.getElementById('depart').value;
        const arrivee = document.getElementById('arrivee').value;
        
        if (depart && arrivee && depart !== arrivee) {
            const distance = villesTogo[depart].distances[arrivee];
            const duree = Math.round(distance / 60 * 10) / 10; // Estimation 60km/h
            
            document.getElementById('distance').textContent = distance;
            document.getElementById('duree').textContent = duree;
            
            // Mettre à jour le prix approximatif
            const classe = document.getElementById('classe').value;
            const prixUnitaire = distance * tarifs[classe];
            document.getElementById('prix').textContent = prixUnitaire;
            
            // Mettre à jour l'affichage de la route sur la carte
            updateRouteDisplay(depart, arrivee);
        } else {
            document.getElementById('distance').textContent = '--';
            document.getElementById('duree').textContent = '--';
            document.getElementById('prix').textContent = '--';
        }
    }
    
    // Mettre à jour le prix quand la classe change
    document.getElementById('classe').addEventListener('change', function() {
        const depart = document.getElementById('depart').value;
        const arrivee = document.getElementById('arrivee').value;
        
        if (depart && arrivee && depart !== arrivee) {
            const distance = villesTogo[depart].distances[arrivee];
            const classe = this.value;
            const prixUnitaire = distance * tarifs[classe];
            document.getElementById('prix').textContent = prixUnitaire;
        }
    });
    
    // Fonction pour charger les tickets
    function loadTickets() {
        const ticketsContainer = document.getElementById('ticketsContainer');
        ticketsContainer.innerHTML = '';
        
        let tickets = JSON.parse(localStorage.getItem('tickets'));
        
        // Filtrer par statut si un filtre est appliqué
        const filterStatus = document.getElementById('filterStatus').value;
        if (filterStatus !== 'all') {
            tickets = tickets.filter(ticket => ticket.statut === filterStatus);
        }
        
        // Filtrer par recherche si un terme est saisi
        const searchTerm = document.getElementById('searchTickets').value.toLowerCase();
        if (searchTerm) {
            tickets = tickets.filter(ticket => 
                ticket.nom.toLowerCase().includes(searchTerm) || 
                ticket.depart.toLowerCase().includes(searchTerm) || 
                ticket.arrivee.toLowerCase().includes(searchTerm) ||
                ticket.id.toString().includes(searchTerm)
            );
        }
        
        if (tickets.length === 0) {
            ticketsContainer.innerHTML = '<p class="no-tickets">Aucun ticket trouvé.</p>';
            return;
        }
        
        // Trier par date de réservation (du plus récent au plus ancien)
        tickets.sort((a, b) => new Date(b.dateReservation) - new Date(a.dateReservation));
        
        tickets.forEach(ticket => {
            const ticketElement = document.createElement('div');
            ticketElement.className = 'ticket';
            ticketElement.innerHTML = `
                <span class="ticket-status status-${ticket.statut}">${ticket.statut}</span>
                <h3>Ticket #${ticket.id}</h3>
                <p><i class="fas fa-user"></i> ${ticket.nom}</p>
                <p><i class="fas fa-route"></i> ${ticket.depart} → ${ticket.arrivee}</p>
                <p><i class="fas fa-calendar-alt"></i> ${ticket.date} à ${ticket.heure}</p>
                <p><i class="fas fa-users"></i> ${ticket.places} place(s) - ${ticket.classe}</p>
                <p><i class="fas fa-money-bill-wave"></i> ${ticket.prixTotal} FCFA</p>
                <div class="actions">
                    <button class="btn btn-details" data-id="${ticket.id}">
                        <i class="fas fa-eye"></i> Détails
                    </button>
                    ${ticket.statut === 'confirmé' ? `
                    <button class="btn btn-annuler" data-id="${ticket.id}">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    ` : ''}
                    <button class="btn btn-imprimer" data-id="${ticket.id}">
                        <i class="fas fa-print"></i> Imprimer
                    </button>
                </div>
            `;
            
            ticketsContainer.appendChild(ticketElement);
        });
        
        // Ajouter les événements pour les boutons
        document.querySelectorAll('.btn-annuler').forEach(btn => {
            btn.addEventListener('click', function() {
                const ticketId = parseInt(this.getAttribute('data-id'));
                annulerTicket(ticketId);
            });
        });
        
        document.querySelectorAll('.btn-imprimer').forEach(btn => {
            btn.addEventListener('click', function() {
                const ticketId = parseInt(this.getAttribute('data-id'));
                imprimerTicket(ticketId);
            });
        });
        
        document.querySelectorAll('.btn-details').forEach(btn => {
            btn.addEventListener('click', function() {
                const ticketId = parseInt(this.getAttribute('data-id'));
                showTicketDetails(ticketId);
            });
        });
    }
    
    // Recherche et filtrage des tickets
    document.getElementById('searchTickets').addEventListener('input', loadTickets);
    document.getElementById('filterStatus').addEventListener('change', loadTickets);
    
    // Fonction pour annuler un ticket
    function annulerTicket(ticketId) {
        const tickets = JSON.parse(localStorage.getItem('tickets'));
        const ticketIndex = tickets.findIndex(t => t.id === ticketId);
        
        if (ticketIndex !== -1) {
            tickets[ticketIndex].statut = 'annulé';
            localStorage.setItem('tickets', JSON.stringify(tickets));
            loadTickets();
            showAlert('success', 'Ticket annulé avec succès');
        }
    }
    
    // Fonction pour imprimer un ticket
    function imprimerTicket(ticketId) {
        const tickets = JSON.parse(localStorage.getItem('tickets'));
        const ticket = tickets.find(t => t.id === ticketId);
        
        if (ticket) {
            const printContent = `
                <div class="ticket-print">
                    <div class="print-header">
                        <img src="logo-sotral.png" alt="Logo SOTRAL" class="print-logo">
                        <h1>SOTRAL TOGO</h1>
                        <h2>Ticket de Bus</h2>
                    </div>
                    
                    <div class="print-details">
                        <div class="detail-row">
                            <span class="detail-label">N° Ticket:</span>
                            <span class="detail-value">#${ticket.id}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Passager:</span>
                            <span class="detail-value">${ticket.nom}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Trajet:</span>
                            <span class="detail-value">${ticket.depart} → ${ticket.arrivee}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Date:</span>
                            <span class="detail-value">${ticket.date} à ${ticket.heure}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Classe:</span>
                            <span class="detail-value">${ticket.classe}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Places:</span>
                            <span class="detail-value">${ticket.places}</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Prix:</span>
                            <span class="detail-value">${ticket.prixTotal} FCFA</span>
                        </div>
                        <div class="detail-row">
                            <span class="detail-label">Statut:</span>
                            <span class="detail-value status-${ticket.statut}">${ticket.statut}</span>
                        </div>
                    </div>
                    
                    <div class="print-barcode">
                        <div class="barcode">▮ ▮ ▮ ▮ ▮ ▮ ▮ ▮ ▮ ▮</div>
                        <div class="barcode-number">${ticket.id}</div>
                    </div>
                    
                    <div class="print-footer">
                        <p>Merci de voyager avec SOTRAL TOGO</p>
                        <p>Réservé le: ${ticket.dateReservation}</p>
                    </div>
                </div>
            `;
            
            const printWindow = window.open('', '_blank');
            printWindow.document.write(`
                <html>
                    <head>
                        <title>Ticket SOTRAL #${ticket.id}</title>
                        <style>
                            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
                            .ticket-print { max-width: 500px; margin: 0 auto; border: 2px solid #006747; padding: 20px; }
                            .print-header { text-align: center; margin-bottom: 20px; }
                            .print-logo { height: 60px; margin-bottom: 10px; }
                            .print-header h1 { color: #006747; margin: 5px 0; font-size: 24px; }
                            .print-header h2 { margin: 5px 0; font-size: 20px; }
                            .print-details { margin: 20px 0; }
                            .detail-row { display: flex; justify-content: space-between; margin-bottom: 8px; padding-bottom: 8px; border-bottom: 1px dashed #ddd; }
                            .detail-label { font-weight: bold; color: #555; }
                            .print-barcode { text-align: center; margin: 30px 0; }
                            .barcode { letter-spacing: 5px; font-size: 24px; }
                            .barcode-number { letter-spacing: 2px; margin-top: 5px; }
                            .print-footer { text-align: center; margin-top: 20px; font-size: 14px; color: #666; }
                            .status-confirmé { color: #155724; }
                            .status-annulé { color: #721c24; }
                            .status-utilisé { color: #383d41; }
                            @media print {
                                body { padding: 0; }
                                .ticket-print { border: none; padding: 10px; }
                            }
                        </style>
                    </head>
                    <body>
                        ${printContent}
                        <script>
                            window.onload = function() { 
                                window.print(); 
                                setTimeout(function() { window.close(); }, 1000); 
                            }
                        </script>
                    </body>
                </html>
            `);
            printWindow.document.close();
        }
    }
    
    // Fonction pour afficher les détails d'un ticket dans un modal
    function showTicketDetails(ticketId) {
        const tickets = JSON.parse(localStorage.getItem('tickets'));
        const ticket = tickets.find(t => t.id === ticketId);
        
        if (ticket) {
            const modalContent = `
                <h2>Détails du Ticket #${ticket.id}</h2>
                <div class="ticket-details">
                    <div class="detail-item">
                        <span class="detail-label">Passager:</span>
                        <span class="detail-value">${ticket.nom}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Trajet:</span>
                        <span class="detail-value">${ticket.depart} → ${ticket.arrivee}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Date et heure:</span>
                        <span class="detail-value">${ticket.date} à ${ticket.heure}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Classe:</span>
                        <span class="detail-value">${ticket.classe}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Nombre de places:</span>
                        <span class="detail-value">${ticket.places}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Distance:</span>
                        <span class="detail-value">${ticket.distance} km</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Prix unitaire:</span>
                        <span class="detail-value">${ticket.prixUnitaire} FCFA</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Prix total:</span>
                        <span class="detail-value">${ticket.prixTotal} FCFA</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Statut:</span>
                        <span class="detail-value status-${ticket.statut}">${ticket.statut}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Date de réservation:</span>
                        <span class="detail-value">${ticket.dateReservation}</span>
                    </div>
                </div>
                <div class="modal-actions">
                    <button class="btn-modal btn-print" data-id="${ticket.id}">
                        <i class="fas fa-print"></i> Imprimer
                    </button>
                    ${ticket.statut === 'confirmé' ? `
                    <button class="btn-modal btn-cancel" data-id="${ticket.id}">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    ` : ''}
                    <button class="btn-modal btn-close">
                        <i class="fas fa-times"></i> Fermer
                    </button>
                </div>
            `;
            
            document.getElementById('ticketModalContent').innerHTML = modalContent;
            openModal('ticketModal');
            
            // Ajouter les événements pour les boutons du modal
            document.querySelector('.btn-print')?.addEventListener('click', function() {
                imprimerTicket(ticketId);
            });
            
            document.querySelector('.btn-cancel')?.addEventListener('click', function() {
                annulerTicket(ticketId);
                closeModal('ticketModal');
            });
            
            document.querySelector('.btn-close').addEventListener('click', function() {
                closeModal('ticketModal');
            });
        }
    }
    
    // Fonction pour afficher un ticket dans un modal après réservation
    function showTicketModal(ticket) {
        const modalContent = `
            <h2>Réservation confirmée!</h2>
            <div class="confirmation-message">
                <p>Votre ticket a été réservé avec succès.</p>
                <p>Numéro de ticket: <strong>#${ticket.id}</strong></p>
            </div>
            <div class="ticket-summary">
                <div class="summary-item">
                    <span class="summary-label">Passager:</span>
                    <span class="summary-value">${ticket.nom}</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">Trajet:</span>
                    <span class="summary-value">${ticket.depart} → ${ticket.arrivee}</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">Date:</span>
                    <span class="summary-value">${ticket.date} à ${ticket.heure}</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">Prix total:</span>
                    <span class="summary-value">${ticket.prixTotal} FCFA</span>
                </div>
            </div>
            <div class="modal-actions">
                <button class="btn-modal btn-print" data-id="${ticket.id}">
                    <i class="fas fa-print"></i> Imprimer
                </button>
                <button class="btn-modal btn-close">
                    <i class="fas fa-check"></i> Compris
                </button>
            </div>
        `;
        
        document.getElementById('ticketModalContent').innerHTML = modalContent;
        openModal('ticketModal');
        
        // Ajouter les événements pour les boutons du modal
        document.querySelector('.btn-print').addEventListener('click', function() {
            imprimerTicket(ticket.id);
        });
        
        document.querySelector('.btn-close').addEventListener('click', function() {
            closeModal('ticketModal');
        });
    }
    
    // Fonctions pour gérer les modals
    function openModal(modalId) {
        document.getElementById(modalId).style.display = 'block';
        document.body.style.overflow = 'hidden';
    }
    
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
        document.body.style.overflow = 'auto';
    }
    
    // Fermer les modals en cliquant en dehors
    window.addEventListener('click', function(event) {
        if (event.target.className === 'modal') {
            event.target.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    });
    
    // Fermer les modals avec le bouton de fermeture
    document.querySelectorAll('.close-modal').forEach(btn => {
        btn.addEventListener('click', function() {
            this.closest('.modal').style.display = 'none';
            document.body.style.overflow = 'auto';
        });
    });
    
    // Gestion des modals de connexion et d'inscription
    document.getElementById('loginBtn').addEventListener('click', function() {
        openModal('loginModal');
    });
    
    document.getElementById('registerBtn').addEventListener('click', function() {
        openModal('registerModal');
    });
    
    // Formulaire de connexion
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const email = document.getElementById('loginEmail').value;
        const password = document.getElementById('loginPassword').value;
        
        // Ici, vous devriez vérifier les identifiants avec votre système d'authentification
        showAlert('success', 'Connexion réussie (simulation)');
        closeModal('loginModal');
    });
    
    // Formulaire d'inscription
    document.getElementById('registerForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const name = document.getElementById('regName').value;
        const email = document.getElementById('regEmail').value;
        const phone = document.getElementById('regPhone').value;
        const password = document.getElementById('regPassword').value;
        const confirmPassword = document.getElementById('regConfirmPassword').value;
        
        if (password !== confirmPassword) {
            showAlert('error', 'Les mots de passe ne correspondent pas');
            return;
        }
        
        // Enregistrer le nouvel utilisateur (simulation)
        const newUser = { name, email, phone, password };
        const users = JSON.parse(localStorage.getItem('users'));
        users.push(newUser);
        localStorage.setItem('users', JSON.stringify(users));
        
        showAlert('success', 'Inscription réussie! Vous pouvez maintenant vous connecter.');
        closeModal('registerModal');
    });
    
    // Fonction pour afficher des messages d'alerte
    function showAlert(type, message) {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} animate__animated animate__fadeInDown`;
        alertDiv.textContent = message;
        
        document.body.appendChild(alertDiv);
        
        setTimeout(() => {
            alertDiv.classList.add('animate__fadeOutUp');
            setTimeout(() => alertDiv.remove(), 500);
        }, 3000);
    }
    
    // Style pour les alertes
    const alertStyle = document.createElement('style');
    alertStyle.textContent = `
        .alert {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            padding: 15px 25px;
            border-radius: 5px;
            color: white;
            font-weight: 600;
            z-index: 1100;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.2);
        }
        .alert-success {
            background-color: #28a745;
        }
        .alert-error {
            background-color: #dc3545;
        }
    `;
    document.head.appendChild(alertStyle);
    
    // Charger les horaires
    function loadHoraires() {
        const horaires = [
            { depart: 'Lomé', arrivee: 'Kara', heures: ['06:00', '08:00', '12:00', '16:00', '18:00'] },
            { depart: 'Lomé', arrivee: 'Sokodé', heures: ['06:30', '09:00', '13:00', '15:30'] },
            { depart: 'Lomé', arrivee: 'Atakpamé', heures: ['07:00', '10:00', '14:00', '17:00'] },
            { depart: 'Kara', arrivee: 'Lomé', heures: ['05:00', '07:00', '11:00', '15:00', '17:00'] },
            { depart: 'Sokodé', arrivee: 'Lomé', heures: ['06:00', '08:30', '12:30', '15:00'] },
            { depart: 'Atakpamé', arrivee: 'Lomé', heures: ['06:00', '09:00', '13:00', '16:00'] }
        ];
        
        let horairesHTML = '<div class="schedule-tabs">';
        
        // Créer des onglets pour chaque ville de départ
        const villesDepart = [...new Set(horaires.map(h => h.depart))];
        villesDepart.forEach((ville, index) => {
            horairesHTML += `<button class="tab-btn ${index === 0 ? 'active' : ''}" data-ville="${ville}">${ville}</button>`;
        });
        
        horairesHTML += '</div><div class="schedule-content">';
        
        // Créer le contenu pour chaque ville de départ
        villesDepart.forEach((ville, index) => {
            const horairesVille = horaires.filter(h => h.depart === ville);
            
            horairesHTML += `<div class="tab-content ${index === 0 ? 'active' : ''}" data-ville="${ville}">`;
            horairesHTML += `<h3>Départs de ${ville}</h3>`;
            
            horairesVille.forEach(horaire => {
                horairesHTML += `
                    <div class="schedule-item">
                        <div class="schedule-route">${horaire.depart} → ${horaire.arrivee}</div>
                        <div class="schedule-times">
                            ${horaire.heures.map(heure => `<span class="time-badge">${heure}</span>`).join('')}
                        </div>
                    </div>
                `;
            });
            
            horairesHTML += '</div>';
        });
        
        horairesHTML += '</div>';
        
        document.querySelector('.schedule-container').innerHTML = horairesHTML;
        
        // Gérer le changement d'onglets
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const ville = this.getAttribute('data-ville');
                
                // Mettre à jour les boutons d'onglet
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                
                // Mettre à jour le contenu des onglets
                document.querySelectorAll('.tab-content').forEach(content => {
                    content.classList.remove('active');
                    if (content.getAttribute('data-ville') === ville) {
                        content.classList.add('active');
                    }
                });
            });
        });
    }
    
    // Charger les tarifs
    function loadTarifs() {
        const pricingHTML = `
            <div class="pricing-cards">
                <div class="pricing-card">
                    <h3>Économique</h3>
                    <div class="price">${tarifs.Economique} FCFA/km</div>
                    <ul class="features">
                        <li><i class="fas fa-check"></i> Sièges standard</li>
                        <li><i class="fas fa-check"></i> Climatisation</li>
                        <li><i class="fas fa-check"></i> Bagage 20kg inclus</li>
                        <li><i class="fas fa-times"></i> Wi-Fi non disponible</li>
                    </ul>
                </div>
                <div class="pricing-card featured">
                    <h3>Confort</h3>
                    <div class="price">${tarifs.Confort} FCFA/km</div>
                    <ul class="features">
                        <li><i class="fas fa-check"></i> Sièges plus larges</li>
                        <li><i class="fas fa-check"></i> Climatisation</li>
                        <li><i class="fas fa-check"></i> Bagage 30kg inclus</li>
                        <li><i class="fas fa-check"></i> Wi-Fi disponible</li>
                    </ul>
                </div>
                <div class="pricing-card">
                    <h3>VIP</h3>
                    <div class="price">${tarifs.VIP} FCFA/km</div>
                    <ul class="features">
                        <li><i class="fas fa-check"></i> Sièges spacieux</li>
                        <li><i class="fas fa-check"></i> Climatisation</li>
                        <li><i class="fas fa-check"></i> Bagage 40kg inclus</li>
                        <li><i class="fas fa-check"></i> Wi-Fi haut débit</li>
                        <li><i class="fas fa-check"></i> Collation offerte</li>
                    </ul>
                </div>
            </div>
            <div class="pricing-example">
                <h3>Exemple de calcul</h3>
                <p>Pour un trajet Lomé-Kara (413 km):</p>
                <ul>
                    <li>Économique: 413 km × ${tarifs.Economique} FCFA = ${413 * tarifs.Economique} FCFA</li>
                    <li>Confort: 413 km × ${tarifs.Confort} FCFA = ${413 * tarifs.Confort} FCFA</li>
                    <li>VIP: 413 km × ${tarifs.VIP} FCFA = ${413 * tarifs.VIP} FCFA</li>
                </ul>
            </div>
        `;
        
        document.querySelector('.pricing-container').innerHTML = pricingHTML;
    }
    
    // Charger la section contact
    function loadContact() {
        const contactHTML = `
            <div class="contact-info">
                <div class="contact-method">
                    <i class="fas fa-phone-alt"></i>
                    <h3>Téléphone</h3>
                    <p>+228 22 21 20 19</p>
                    <p>Service client disponible 24h/24</p>
                </div>
                <div class="contact-method">
                    <i class="fas fa-envelope"></i>
                    <h3>Email</h3>
                    <p>contact@sotral.tg</p>
                    <p>Réponse sous 24 heures</p>
                </div>
                <div class="contact-method">
                    <i class="fas fa-map-marker-alt"></i>
                    <h3>Adresse</h3>
                    <p>Avenue de la Libération</p>
                    <p>Lomé, Togo</p>
                </div>
            </div>
            <form id="contactForm" class="contact-form">
                <h3>Envoyez-nous un message</h3>
                <div class="form-group">
                    <label for="contactName">Nom complet:</label>
                    <input type="text" id="contactName" required>
                </div>
                <div class="form-group">
                    <label for="contactEmail">Email:</label>
                    <input type="email" id="contactEmail" required>
                </div>
                <div class="form-group">
                    <label for="contactSubject">Sujet:</label>
                    <input type="text" id="contactSubject" required>
                </div>
                <div class="form-group">
                    <label for="contactMessage">Message:</label>
                    <textarea id="contactMessage" rows="5" required></textarea>
                </div>
                <button type="submit" class="btn-contact">Envoyer</button>
            </form>
        `;
        
        document.querySelector('.contact-container').innerHTML = contactHTML;
        
        // Gérer l'envoi du formulaire de contact
        document.getElementById('contactForm')?.addEventListener('submit', function(e) {
            e.preventDefault();
            showAlert('success', 'Votre message a été envoyé. Nous vous répondrons bientôt!');
            this.reset();
        });
    }
    
    // Mettre à jour l'affichage de la route sur la carte (simulation)
    function updateRouteDisplay(depart, arrivee) {
        const mapPreview = document.querySelector('#mapPreview .route-display');
        mapPreview.innerHTML = `
            <div class="route-line" style="height: ${villesTogo[depart].distances[arrivee] / 10}px; transform: rotate(${Math.random() * 30 - 15}deg);"></div>
            <div class="route-point start" style="top: 0; left: 50%;">
                <span>${depart}</span>
            </div>
            <div class="route-point end" style="bottom: 0; left: 50%;">
                <span>${arrivee}</span>
            </div>
        `;
    }
    
    // Définir la date minimale (aujourd'hui)
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('date').setAttribute('min', today);
    
    // Empêcher la sélection de dates passées
    document.getElementById('date').addEventListener('input', function() {
        const selectedDate = new Date(this.value);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        if (selectedDate < today) {
            this.value = today.toISOString().split('T')[0];
            showAlert('error', 'Vous ne pouvez pas sélectionner une date passée');
        }
    });
    
    // Initialiser l'affichage de la route si des valeurs sont déjà sélectionnées
    if (document.getElementById('depart').value && document.getElementById('arrivee').value) {
        updateRouteInfo();
    }
});