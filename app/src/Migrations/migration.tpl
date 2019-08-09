<?php declare(strict_types = 1);

namespace <namespace>;

use Doctrine\DBAL\DBALException;
use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
* Auto-generated Migration: Please modify to your needs!
*/
class Version<version> extends AbstractMigration
{
    public function getDescription() : string
    {
        return '';
    }

    /**
     * @param Schema $schema
     *
     * @return void
     * @throws DBALException
     */
    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
<up>
    }

    /**
     * @param Schema $schema
     *
     * @return void
     * @throws DBALException
     */
    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
<down>
    }
}