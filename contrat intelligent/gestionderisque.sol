// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GestionnaireRisqueContrepartie {
    // Structure de données pour représenter une contrepartie
    struct Contrepartie {
        address portefeuille;
        uint256 scoreCredit;
        uint256 limiteExposition;
        uint256 expositionCourante;
        bool estActif;
    }

    // Variables d'état
    mapping(address => Contrepartie) public contreparties;

    // Événements
    event ContrepartieAjoutee(address indexed contrepartie, uint256 limiteExposition);
    event ExpositionMiseAJour(address indexed contrepartie, uint256 nouvelleExposition);
    event LimiteDepassee(address indexed contrepartie, uint256 exposition);

    // Ajouter une contrepartie
    function ajouterContrepartie(
        address _portefeuille,
        uint256 _scoreCredit,
        uint256 _limiteExposition
    ) public {
     require(contreparties[_portefeuille].estActif == false, "Contrepartie existe deja.");

        contreparties[_portefeuille] = Contrepartie({
            portefeuille: _portefeuille,
            scoreCredit: _scoreCredit,
            limiteExposition: _limiteExposition,
            expositionCourante: 0,
            estActif: true
        });
        emit ContrepartieAjoutee(_portefeuille, _limiteExposition);
    }

    // Mettre à jour l'exposition
    function mettreAJourExposition(address _portefeuille, uint256 _nouvelleExposition) public {
        require(contreparties[_portefeuille].estActif, "Contrepartie inexistante.");
        Contrepartie storage c = contreparties[_portefeuille];
        c.expositionCourante = _nouvelleExposition;
        emit ExpositionMiseAJour(_portefeuille, _nouvelleExposition);

        // Vérifier si la limite est dépassée
        if (c.expositionCourante > c.limiteExposition) {
            emit LimiteDepassee(_portefeuille, c.expositionCourante);
        }
    }

    // Calculer le risque
    function calculerRisque(address _portefeuille) public view returns (uint256) {
        Contrepartie storage c = contreparties[_portefeuille];
        require(c.estActif, "Contrepartie inexistante.");
        require(c.limiteExposition > 0, "Limite d'exposition invalide.");
        return (c.expositionCourante * 100) / (c.limiteExposition * c.scoreCredit);
    }
}