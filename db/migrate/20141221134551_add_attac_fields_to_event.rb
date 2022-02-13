class AddAttacFieldsToEvent < ActiveRecord::Migration[4.2]
  def change

    # Anzahl für mehrtägige Veranstaltungen
    #   1-4 sich fortsetzende Veranstaltungen
    #   default 1
    add_column :events, :number_of_repeats, :integer, default: 1
    # TODO wie soll das ge-scheduled werden?

    # Andere Veranstaltungsorte
    add_column :events, :other_locations, :text

    # Methoden:
    # Mit welcher/n Methode/n soll die Veranstaltung durchgeführt werden? (bitte ankreuzen)
    #   Referat
    #   Referat/Diskussion
    #   Podiumsdiskussion
    #   Fishbowl
    #   OpenSpace
    #   Zukunftskonferenz
    #   WorldCafé
    add_column :events, :methods, :text

    # Material:
    #   Beamer gewünscht ja / nein
    # -> tech_rider

    # Zielgruppe
    #   keine Vorkenntnisse
    #   Vorinformationen vorhanden (Vertiefung erwünscht)
    #   (ggf.)

    add_column :events, :target_audience_experience, :text
    add_column :events, :target_audience_experience_text, :text

  end
end
